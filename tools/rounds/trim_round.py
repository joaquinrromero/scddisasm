#!/usr/bin/env python3
"""Drops from a zone file (src/MD Port/Zones/<R>.asm) every chunk that is not reachable from the zone roots in
<R>/_symbols.txt (objects are global now, so the per-round object code is dead). Reachability follows identifiers
and fall-through of code chunks.   usage (repo root): python3 tools/rounds/trim_round.py R12B [--dry]"""
import re, sys
R = sys.argv[1]; DRY = "--dry" in sys.argv
f = f"src/MD Port/Zones/{R}.asm"; lines = open(f).read().replace("\r", "").split("\n")
chunks = []; cur = None; head = []
for l in lines:
    m = re.match(r'^([A-Za-z_]\w*):', l)
    if m and not re.match(rf'^{R}_(?:loc|locret)_', m[1]):
        cur = [m[1], [l]]; chunks.append(cur)
    elif cur: cur[1].append(l)
    else: head.append(l)
names = {c[0]: i for i, c in enumerate(chunks)}
lab = {}
for i, (n, ls) in enumerate(chunks):
    for l in ls:
        m = re.match(r'^([A-Za-z_]\w*):', l)
        if m: lab[m[1]] = i
roots = [v for l in open(f"src/MD Port/Zones/{R}/_symbols.txt").read().split("\n")[1:] if "=" in l for v in [l.split("=", 1)[1]] if v.startswith(R + "_")]
ID = re.compile(r'[A-Za-z_]\w*')
def falls(ls):
    last = [l.split(';')[0].strip() for l in ls if l.split(';')[0].strip() and not l.split(';')[0].strip().endswith(':')]
    if not last: return True
    x = last[-1].split()[0].lower()
    return not (x in ('rts', 'jmp', 'bra', 'bra.s', 'bra.w', 'rte', 'even', 'incbin') or x.startswith('dc.') or x.startswith('jmp'))
keep = set(); todo = [lab[r] for r in roots + [R + "_LevelDemo"] if r in lab]   # LevelDemo = BG chunks, read right after LevelChunks
while todo:
    i = todo.pop()
    if i in keep: continue
    keep.add(i)
    for l in chunks[i][1]:
        for w in ID.findall(l.split(';')[0]):
            if w in lab and lab[w] not in keep: todo.append(lab[w])
    if falls(chunks[i][1]) and i + 1 < len(chunks): todo.append(i + 1)
dropped = [chunks[i][0] for i in range(len(chunks)) if i not in keep]
nb = sum(len(chunks[i][1]) for i in range(len(chunks)) if i not in keep)
print(f"{R}: keep {len(keep)}/{len(chunks)} chunks, drop {len(dropped)} ({nb} lines)")
if not DRY:
    out = head + [l for i in range(len(chunks)) if i in keep for l in chunks[i][1]]
    open(f, "w", newline="\n").write("\n".join(out))
