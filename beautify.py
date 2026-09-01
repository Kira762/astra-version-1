#!/usr/bin/env python3
"""Luau Beautifier v3 - fixes -> operator and double spaces"""
import sys
import re

KEYWORDS = {
    'and', 'break', 'continue', 'do', 'else', 'elseif', 'end', 'export',
    'for', 'function', 'if', 'in', 'local', 'not', 'or', 'repeat',
    'return', 'then', 'type', 'until', 'while', 'true', 'false', 'nil'
}

def split_keywords(word):
    if word in KEYWORDS:
        return [word]
    for kw in sorted(KEYWORDS, key=len, reverse=True):
        if word.startswith(kw) and len(word) > len(kw):
            rest = word[len(kw):]
            if not rest[0].isalpha() or rest[0] == '_':
                return [kw] + split_keywords(rest)
            for kw2 in KEYWORDS:
                if rest.startswith(kw2):
                    return [kw] + split_keywords(rest)
    return [word]

def tokenize(content):
    tokens = []
    i = 0; n = len(content)
    while i < n:
        ch = content[i]
        if ch in ' \t': i += 1; continue
        if ch == '\n': tokens.append(('NL', '\n')); i += 1; continue
        # Comments
        if ch == '-' and i+1 < n and content[i+1] == '-':
            if i+3 < n and content[i+2] == '[' and content[i+3] == '[':
                eq = 0; j = i+4
                if j < n and content[j] == '=':
                    while j < n and content[j] == '=': eq += 1; j += 1
                    if j < n and content[j] == '[':
                        brk = '['*(2+eq)+']'*(eq+2); end = content.find(brk, j+1)
                        if end != -1: tokens.append(('COMMENT', content[i:end+len(brk)])); i = end+len(brk); continue
                end = content.find(']]', i+4)
                if end != -1: tokens.append(('COMMENT', content[i:end+2])); i = end+2; continue
            end = content.find('\n', i)
            if end == -1: tokens.append(('COMMENT', content[i:])); i = n
            else: tokens.append(('COMMENT', content[i:end])); i = end
            continue
        # Long strings
        if ch == '[':
            eq = 0; j = i+1
            if j < n and content[j] == '=':
                while j < n and content[j] == '=': eq += 1; j += 1
                if j < n and content[j] == '[':
                    brk = '['*(2+eq)+']'*(eq+2); end = content.find(brk, j+1)
                    if end != -1: tokens.append(('STRING', content[i:end+len(brk)])); i = end+len(brk); continue
            elif j < n and content[j] == '[':
                end = content.find(']]', i+2)
                if end != -1: tokens.append(('STRING', content[i:end+2])); i = end+2; continue
        # Strings
        if ch in ('"', "'", '`'):
            q = ch; j = i+1
            while j < n:
                if content[j] == '\\': j += 2; continue
                if content[j] == q: j += 1; break
                if q != '`' and content[j] == '\n': break
                j += 1
            tokens.append(('STRING', content[i:j])); i = j; continue
        # Numbers
        if ch.isdigit() or (ch == '.' and i+1 < n and content[i+1].isdigit()):
            s = i
            if ch == '0' and i+1 < n and content[i+1] in 'xXbBoO':
                i += 2
                while i < n and (content[i].isalnum() or content[i] == '.'): i += 1
            else:
                while i < n and (content[i].isdigit() or content[i] == '.'): i += 1
                if i < n and content[i] in 'eE':
                    i += 1
                    if i < n and content[i] in '+-': i += 1
                    while i < n and content[i].isdigit(): i += 1
            tokens.append(('NUMBER', content[s:i])); continue
        # Identifiers
        if ch.isalpha() or ch == '_':
            s = i
            while i < n and (content[i].isalnum() or content[i] == '_'): i += 1
            word = content[s:i]
            for part in split_keywords(word):
                tokens.append(('KEYWORD' if part in KEYWORDS else 'IDENT', part))
            continue
        # Three-char ops
        if i+2 < n and content[i:i+3] == '...':
            tokens.append(('OP', '...')); i += 3; continue
        # Two-char ops
        if i+1 < n:
            two = content[i:i+2]
            if two in ('==', '~=', '<=', '>=', '..', '::', '->'):
                tokens.append(('OP', two)); i += 2; continue
        # Single chars
        if ch in '()[]{}.,:;':
            tokens.append(('DELIM', ch)); i += 1
        elif ch in '=+-*/%^<>~#@$?\\|':
            tokens.append(('OP', ch)); i += 1
        else:
            tokens.append(('CHAR', ch)); i += 1
    return tokens

def format_tokens(tokens):
    output = []
    indent = 0
    IND = '    '
    
    def prev():
        for t in reversed(output):
            if t[0] not in ('WS', 'NL'): return t
        return None
    
    def nxt(idx):
        for j in range(idx+1, len(tokens)):
            if tokens[j][0] not in ('WS', 'NL'): return tokens[j]
        return None
    
    def add_ws():
        """Add a space only if the last non-whitespace token isn't already followed by whitespace."""
        if output:
            last = output[-1]
            if last[0] == 'WS': return  # already has whitespace
            if last[0] == 'NL': return  # newline, indent will follow
            if last[0] == 'IND': return  # indent, don't add ws right after
        output.append(('WS', ' '))
    
    def add_kw(val):
        """Add keyword with proper spacing."""
        output.append(('KW', val))
        output.append(('WS', ' '))
    
    def add_nl_indent():
        """Add newline + current indent."""
        # Avoid double newlines
        if output and output[-1][0] == 'NL': return
        output.append(('NL', '\n'))
        output.append(('IND', IND*indent))
    
    i = 0; n = len(tokens)
    while i < n:
        typ, val = tokens[i]
        p = prev()
        ne = nxt(i)
        
        if typ == 'NL':
            if output and output[-1][0] != 'NL':
                output.append(('NL', '\n'))
            i += 1; continue
        
        if typ == 'WS': i += 1; continue
        
        if typ == 'COMMENT':
            add_ws()
            output.append(('COMMENT', val))
            i += 1; continue
        
        if typ == 'KEYWORD':
            if val in ('end', 'until'):
                if indent > 0: indent -= 1
                add_nl_indent()
                add_kw(val)
                i += 1; continue
            
            if val == 'else':
                if indent > 0: indent -= 1
                add_nl_indent()
                indent += 1
                add_kw(val)
                i += 1; continue
            
            if val == 'elseif':
                add_ws()
                add_kw(val)
                i += 1; continue
            
            if val == 'then':
                add_ws()
                add_kw(val)
                add_nl_indent()
                i += 1; continue
            
            if val == 'do':
                add_ws()
                add_kw(val)
                add_nl_indent()
                i += 1; continue
            
            if val == 'function':
                is_block = False
                if p is None: is_block = True
                elif p[0] == 'KW' and p[1] in ('local', 'end', 'else'): is_block = True
                elif p[0] == 'DL' and p[1] == '=': is_block = False
                elif p[0] == 'DL' and p[1] in (',', '(', '{'): is_block = False
                elif p[0] == 'OP' and p[1] == '=': is_block = False
                else: is_block = True
                if is_block:
                    add_nl_indent()
                    indent += 1
                else:
                    add_ws()
                add_kw(val)
                i += 1; continue
            
            if val == 'local':
                add_nl_indent()
                add_kw(val)
                i += 1; continue
            
            if val == 'return':
                add_nl_indent()
                add_kw(val)
                i += 1; continue
            
            if val in ('if', 'for', 'while', 'repeat'):
                add_nl_indent()
                indent += 1
                add_kw(val)
                i += 1; continue
            
            if val == 'export':
                add_ws()
                add_kw(val)
                i += 1; continue
            
            if val == 'type':
                if p and p[0] == 'KW' and p[1] == 'export':
                    add_ws()
                else:
                    add_nl_indent()
                add_kw(val)
                i += 1; continue
            
            if val == 'in':
                add_ws()
                add_kw(val)
                i += 1; continue
            
            if val in ('and', 'or', 'not', 'break', 'continue'):
                add_ws()
                add_kw(val)
                i += 1; continue
            
            if val in ('true', 'false', 'nil'):
                add_ws()
                output.append(('KW', val))
                i += 1; continue
            
            output.append(('KW', val))
            i += 1; continue
        
        if typ == 'DELIM':
            if val == ',':
                output.append(('DL', val))
                output.append(('WS', ' '))
            else:
                output.append(('DL', val))
            i += 1; continue
        
        if typ == 'OP':
            if val in ('==', '~=', '<=', '>=', '..', '...', '->'):
                add_ws()
                output.append(('OP', val))
                add_ws()
            elif val in ('+', '*', '/', '%', '^'):
                add_ws()
                output.append(('OP', val))
                add_ws()
            elif val == '-':
                is_unary = (p is None or (p[0] in ('OP', 'DL') and p[1] in ('=', '(', ',', '{', '+', '-', '*', '/', '%', '^', '<', '>', '~', ':', '[', '=>')))
                if is_unary:
                    output.append(('OP', val))
                else:
                    add_ws()
                    output.append(('OP', val))
                    add_ws()
            elif val == '=':
                add_ws()
                output.append(('OP', val))
                add_ws()
            elif val in ('<', '>'):
                add_ws()
                output.append(('OP', val))
                add_ws()
            elif val == '::':
                output.append(('OP', val))
            else:
                output.append(('OP', val))
            i += 1; continue
        
        # Default: ident, number, string
        if p and p[0] in ('ID', 'NUM', 'STR', 'KW'):
            add_ws()
        tmap = {'IDENT': 'ID', 'NUMBER': 'NUM', 'STRING': 'STR'}
        output.append((tmap.get(typ, typ), val))
        i += 1
    
    return output

def render(tokens):
    parts = []
    for typ, val in tokens:
        if typ == 'IND': parts.append(val)
        elif typ == 'NL': parts.append('\n')
        else: parts.append(val)
    return ''.join(parts)

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

tokens = tokenize(body)
print(f"Tokens: {len(tokens)}")

ft = format_tokens(tokens)
result = render(ft)

nulls = result.count('\x00')
print(f"Null bytes: {nulls}")
if nulls > 0: sys.exit(1)

op = result.count('('); cp = result.count(')')
ob = result.count('{'); cb = result.count('}')
print(f"Parens: ({op} / ) {cp}  Braces: {{{ob} / }} {cb}")

oe = len(re.findall(r'\bend\b', body))
ne = len(re.findall(r'\bend\b', result))
print(f"end count: {oe} -> {ne}")

os_c = len(re.findall(r'"[^"\\]*(?:\\.[^"\\]*)*"|\'[^\'\\]*(?:\\.[^\'\\]*)*\'|`[^`\\]*(?:\\.[^`\\]*)*`|\[\[.*?\]\]', body))
ns_c = len(re.findall(r'"[^"\\]*(?:\\.[^"\\]*)*"|\'[^\'\\]*(?:\\.[^\'\\]*)*\'|`[^`\\]*(?:\\.[^`\\]*)*`|\[\[.*?\]\]', result))
print(f"Strings: {os_c} -> {ns_c}")

# Check for -> 
arrows = result.count('->')
print(f"-> arrows: {arrows}")

# Check no broken -> (dash space space gt)
broken_arrows = result.count('-  >')
print(f"Broken arrows (-  >): {broken_arrows}")

output = header + '\n' + result
with open(sys.argv[2], 'w') as f:
    f.write(output)
print(f"Output: {len(output)} bytes, {len(output.splitlines())} lines")
