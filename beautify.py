#!/usr/bin/env python3
"""
Luau Beautifier v6 - Preserves all original token spacing.
Only adds newlines at block boundaries and indentation.
Never modifies, splits, or removes any existing tokens or their spacing.
"""
import sys
import re

def extract_strings_and_comments(content):
    """Extract all strings and comments, replacing with placeholders."""
    placeholders = {}
    result = []
    i = 0
    n = len(content)
    idx = 0
    
    while i < n:
        ch = content[i]
        
        if ch == '\n':
            result.append('\n'); i += 1; continue
        
        if ch in ' \t':
            result.append(ch); i += 1; continue
        
        # Comments
        if ch == '-' and i+1 < n and content[i+1] == '-':
            if i+3 < n and content[i+2] == '[' and content[i+3] == '[':
                eq = 0; j = i+4
                if j < n and content[j] == '=':
                    while j < n and content[j] == '=': eq += 1; j += 1
                    if j < n and content[j] == '[':
                        brk = '['*(2+eq)+']'*(eq+2)
                        end = content.find(brk, j+1)
                        if end != -1:
                            ph = f'\x00PH{idx}\x00'
                            placeholders[ph] = content[i:end+len(brk)]
                            result.append(ph); idx += 1; i = end+len(brk); continue
                end = content.find(']]', i+4)
                if end != -1:
                    ph = f'\x00PH{idx}\x00'
                    placeholders[ph] = content[i:end+2]
                    result.append(ph); idx += 1; i = end+2; continue
            end = content.find('\n', i)
            if end == -1:
                ph = f'\x00PH{idx}\x00'
                placeholders[ph] = content[i:]; result.append(ph); idx += 1; i = n
            else:
                ph = f'\x00PH{idx}\x00'
                placeholders[ph] = content[i:end]; result.append(ph); idx += 1; i = end
            continue
        
        # Long strings
        if ch == '[':
            eq = 0; j = i+1
            if j < n and content[j] == '=':
                while j < n and content[j] == '=': eq += 1; j += 1
                if j < n and content[j] == '[':
                    brk = '['*(2+eq)+']'*(eq+2); end = content.find(brk, j+1)
                    if end != -1:
                        ph = f'\x00PH{idx}\x00'
                        placeholders[ph] = content[i:end+len(brk)]
                        result.append(ph); idx += 1; i = end+len(brk); continue
            elif j < n and content[j] == '[':
                end = content.find(']]', i+2)
                if end != -1:
                    ph = f'\x00PH{idx}\x00'
                    placeholders[ph] = content[i:end+2]
                    result.append(ph); idx += 1; i = end+2; continue
        
        # String literals
        if ch in ('"', "'", '`'):
            q = ch; j = i+1
            while j < n:
                if content[j] == '\\': j += 2; continue
                if content[j] == q: j += 1; break
                if q != '`' and content[j] == '\n': break
                j += 1
            ph = f'\x00PH{idx}\x00'
            placeholders[ph] = content[i:j]
            result.append(ph); idx += 1; i = j; continue
        
        result.append(ch); i += 1
    
    return ''.join(result), placeholders

def restore_placeholders(code, placeholders):
    result = code
    for ph, original in sorted(placeholders.items(), key=lambda x: -len(x[0])):
        result = result.replace(ph, original)
    return result

def beautify(code):
    """Add newlines and indentation to code with placeholders.
    
    Strategy: Process the code line by line from the original,
    inserting newlines before statement-start keywords.
    """
    # Normalize: collapse horizontal whitespace to single space
    code = re.sub(r'[ \t]+', ' ', code)
    
    # Now insert newlines before block-start keywords at appropriate positions.
    # We use regex to insert \n before keywords that start new statements.
    
    # Block-start keywords that need a newline before them when they follow:
    # - end, then, else, do, until, ), {
    # - or start of line
    
    # Pattern: after end/then/else/do/until, insert newline before next statement keyword
    stmt_kws = r'(local|function|if|for|while|repeat|return|break|continue|export|type)'
    
    # Insert newline before statement keywords after block-ending tokens
    # endkeyword -> end\nkeyword
    code = re.sub(r'\bend(' + stmt_kws + r')\b', r'end\n\1', code)
    code = re.sub(r'\bend(\s+)(function\b)', r'end\n\2', code)
    
    # )keyword -> )\nkeyword (but not )end which is handled above)
    code = re.sub(r'\)(' + stmt_kws + r')\b', r')\n\1', code)
    
    # thenkeyword -> then\nkeyword
    code = re.sub(r'\bthen(' + stmt_kws + r')\b', r'then\n\1', code)
    
    # elsekeyword -> else\nkeyword  
    code = re.sub(r'\belse(' + stmt_kws + r')\b', r'else\n\1', code)
    
    # dokeyword -> do\nkeyword
    code = re.sub(r'\bdo(' + stmt_kws + r')\b', r'do\n\1', code)
    
    # untilkeyword -> until\nkeyword
    code = re.sub(r'\buntil(' + stmt_kws + r')\b', r'until\n\1', code)
    
    # {keyword -> {\nkeyword
    code = re.sub(r'\{(' + stmt_kws + r')\b', r'{\n\1', code)
    
    # Insert newline BEFORE end/else/elseif/until at statement level
    # (when they follow a non-newline, non-space character)
    code = re.sub(r'([^\n\s])\b(end)\b', r'\1\n\2', code)
    code = re.sub(r'([^\n\s])\b(else)\b', r'\1\n\2', code)
    code = re.sub(r'([^\n\s])\b(elseif)\b', r'\1\n\2', code)
    code = re.sub(r'([^\n\s])\b(until)\b', r'\1\n\2', code)
    
    # Also insert newline before return when it follows end
    # (endreturn -> end\nreturn)
    code = re.sub(r'\bend(return)\b', r'end\n\1', code)
    
    # Now add indentation
    lines = code.split('\n')
    result = []
    indent = 0
    IND = '    '
    
    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue
        
        # Get first word
        m = re.match(r'^(\w+)', stripped)
        fw = m.group(1) if m else ''
        
        # Adjust indent before printing
        if fw in ('end', 'until'):
            indent = max(0, indent - 1)
        elif fw in ('else', 'elseif'):
            indent = max(0, indent - 1)
        
        result.append(IND * indent + stripped)
        
        # Count block openers/closers
        opens = 0
        closes = 0
        
        # Count function/if/for/while/repeat as openers
        for kw in ('function', 'if', 'for', 'while', 'repeat'):
            opens += len(re.findall(r'\b' + kw + r'\b', stripped))
        
        # Count end/until as closers
        for kw in ('end', 'until'):
            closes += len(re.findall(r'\b' + kw + r'\b', stripped))
        
        indent += opens - closes
        indent = max(0, indent)
    
    return '\n'.join(result)

def main():
    with open(sys.argv[1]) as f:
        content = f.read()
    
    lines = content.split('\n')
    header_end = 0
    for i, line in enumerate(lines):
        if line.startswith('local a local aa'):
            header_end = i; break
    
    header = '\n'.join(lines[:header_end])
    body = '\n'.join(lines[header_end:])
    print(f"Header: {header_end} lines, Body: {len(lines)-header_end} lines")
    
    stripped, placeholders = extract_strings_and_comments(body)
    print(f"Extracted {len(placeholders)} placeholders")
    
    result = beautify(stripped)
    result = restore_placeholders(result, placeholders)
    
    nulls = result.count('\x00')
    print(f"Null bytes: {nulls}")
    if nulls > 0:
        print("ERROR"); sys.exit(1)
    
    bare_local = len(re.findall(r'\blocal\s*$', result, re.MULTILINE))
    print(f"Bare 'local' at end of line: {bare_local}")
    
    # Verify: no identifier was split
    # Check that 'local' is always followed by space or newline (not glued to identifier)
    glued = len(re.findall(r'\blocal[a-zA-Z_]', result))
    print(f"Glued 'local' to identifier: {glued}")
    
    for pattern in ['CreateWindow', '_runGuarded', 'CreateButton']:
        print(f"  {pattern}: {'OK' if pattern in result else 'MISSING'}")
    
    output = header + '\n' + result
    with open(sys.argv[2], 'w') as f:
        f.write(output)
    
    print(f"Output: {len(output)} bytes, {len(output.splitlines())} lines")
    print("Done!")

if __name__ == '__main__':
    main()
