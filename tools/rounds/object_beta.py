#!/usr/bin/env python3
"""
Lists, per object ID, the implementations used across the 70 rounds, grouped into families:
  identical      same code
  minor  (>=90%) small edits (beta remnants, fixes applied in some rounds only)
  moderate (60-90%)  same base with real gimmicks
  different (<60%)   another object that reuses the ID in that zone
Needs: /tmp/used.pkl (layout ID usage, see object_index_scan.py) and the generated sources (CCZ env var).
"""
import sys, os, re, pickle, difflib, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); os.environ.setdefault('CCZ', '/home/claude/work/mdport/src/Level/')
import rlib
used = pickle.load(open('/tmp/used.pkl', 'rb')); CR = pickle.load(open('/tmp/created.pkl','rb'))
num = re.compile(r'#?-?\$[0-9A-Fa-f]+|\b\d+\b')
items = {}
for r in used:
    p = rlib.round_path(r, generated=False)
    if not os.path.exists(p): continue
    rs = rlib.routines(p); by = {x.name: x for x in rs}
    if 'ObjectIndex' not in by: continue
    tg = [m.group(1) for l in by['ObjectIndex'].lines for m in [re.match(r'\s*dc\.l\s+(\w+)', l)] if m]
    for s, n in enumerate(tg):
        x = by.get(n)
        if not x: continue
        seen = {n}; todo = [n]; sig = []
        while todo:                               # closure over the object's own (auto-named) sub-routines
            y = by[todo.pop()]; sig += list(y.sig)
            for l in y.lines:
                for w in re.findall(r'[A-Za-z_]\w*', l.split(';')[0]):
                    z = by.get(w)
                    if z and w not in seen and (rlib.AUTO.fullmatch(w) or w.startswith(n.split('_')[0])): seen.add(w); todo.append(w)
        if len(sig) > 3: items[(r, s + 1)] = (n, tuple(sig))

sim = lambda a, b: difflib.SequenceMatcher(None, a, b, autojunk=False).ratio()
mask = lambda s: tuple(num.sub('N', l) for l in s)
live = {}   # masked sig -> example
for (r, i), (n, sig) in items.items():
    if used[r].get(i) or i in CR[r] or i in (1, 2): live.setdefault(mask(sig), (r, i, n))
cand = {}
for (r, i), (n, sig) in items.items():
    if used[r].get(i) or i in CR[r] or i in (1, 2): continue
    m = mask(sig)
    if m in live: continue
    cand.setdefault(m, []).append((r, i, n))
beta = []; matched = 0
lv = list(live)
for m, rs in cand.items():
    hit = None
    for l in lv:
        if abs(len(l) - len(m)) > 0.5 * max(len(l), len(m)): continue
        sm = difflib.SequenceMatcher(None, m, l, autojunk=False)
        if sm.real_quick_ratio() < .6 or sm.quick_ratio() < .6: continue
        if sm.ratio() >= .6: hit = live[l]; break
    if hit: matched += 1
    else: beta.append((rs, len(m)))
with open('object_beta.txt', 'w') as f:
    f.write("BETA objects = implementations present in the code but never placed in any layout, never created by code (FindObjSlot/morph/fixed RAM slot) and with no >=60%-similar counterpart that is used, in ANY of the 70 rounds.\nKeep the code in Main, NO ObjectIndex entry.\n\n")
    for rs, ln in sorted(beta, key=lambda x: x[0][0][1]):
        z = collections.defaultdict(list)
        for r, i, n in rs: z[r[1]].append(r[2:])
        names = collections.Counter(n for _, _, n in rs).most_common(1)[0][0]
        f.write(f"old ID {rs[0][1]:02X}  {names}  {ln} lines  ; "+' '.join(f"Z{k}:{'/'.join(sorted(v))}" for k, v in sorted(z.items()))+"\n")
print(len(cand), matched, len(beta))
