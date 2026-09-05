#!/usr/bin/env python3
"""Triage differences between original and regenerated bundle modules.

For each original module, finds the best-matching regenerated module and
classifies changed lines as cosmetic (comments/blank/whitespace) or real.
Prints any real code differences for manual review.
"""
import difflib
import re
import sys

sys.path.insert(0, "scripts")
from verify_bundle_equivalence import HEADER_RE, canonicalize, extract_modules


def is_cosmetic(old_line: str, new_line: str) -> bool:
    """True if the pair differs only by comments or surrounding whitespace."""
    def strip_comments(ln: str) -> str:
        # Remove full-line comments and trailing comments (naive but fine for triage;
        # strings containing '--' are rare in this codebase).
        ln = re.sub(r"--\[\[.*?\]\]", "", ln)
        out, depth = "", 0
        i = 0
        while i < len(ln):
            if ln.startswith("--", i):
                break
            out += ln[i]
            i += 1
        return out

    a = re.sub(r"\s+", " ", strip_comments(old_line)).strip()
    b = re.sub(r"\s+", " ", strip_comments(new_line)).strip()
    return a == b


def main():
    old_mods = extract_modules("/tmp/original_version-1.luau")
    new_mods = extract_modules("version-1.luau")

    new_list = [(idx, body.split("\n")) for idx, body in sorted(new_mods.items())]

    suspicious = []
    for oidx in sorted(old_mods):
        old_lines = old_mods[oidx].split("\n")
        matcher = difflib.SequenceMatcher(None, old_lines, autojunk=False)
        best, best_ratio = None, -1.0
        for nidx, new_lines in new_list:
            matcher.set_seq2(new_lines)
            r = matcher.quick_ratio()
            if r < best_ratio - 0.05:
                continue
            matcher.ratio()
            if matcher.ratio() > best_ratio:
                best_ratio, best = matcher.ratio(), (nidx, new_lines)

        nidx, new_lines = best
        sm = difflib.SequenceMatcher(None, old_lines, new_lines, autojunk=False)
        real_diffs = []
        for tag, i1, i2, j1, j2 in sm.get_opcodes():
            if tag == "equal":
                continue
            old_seg = old_lines[i1:i2]
            new_seg = new_lines[j1:j2]
            if tag in ("replace",) and len(old_seg) == len(new_seg):
                if all(is_cosmetic(a, b) for a, b in zip(old_seg, new_seg)):
                    continue
            # Deleted lines that exist verbatim elsewhere in new module = moved; skip
            if tag == "delete":
                if all(any(re.sub(r"\s+", " ", l.strip()) == re.sub(r"\s+", " ", nl.strip()) for nl in new_lines) for l in old_seg if l.strip()):
                    continue
            real_diffs.append((tag, old_seg, new_seg))

        if real_diffs:
            suspicious.append((oidx, nidx, best_ratio, real_diffs))

    print(f"modules needing review: {len(suspicious)}")
    for oidx, nidx, ratio, diffs in suspicious:
        print(f"\n=== old[{oidx}] -> new[{nidx}] (similarity {ratio:.3f}) ===")
        for tag, old_seg, new_seg in diffs[:6]:
            print(f"  [{tag}]")
            for l in old_seg[:8]:
                print(f"    - {l[:150]}")
            for l in new_seg[:8]:
                print(f"    + {l[:150]}")
    if not suspicious:
        print("ALL MODULE DIFFERENCES ARE COSMETIC (comments/whitespace/line moves)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
