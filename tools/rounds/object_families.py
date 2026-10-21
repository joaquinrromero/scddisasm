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
used = pickle.load(open('/tmp/used.pkl', 'rb'))
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
        if not x or not used[r].get(s + 1): continue
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
out = []; stat = collections.Counter()
ids = sorted({i for _, i in items})
for oid in ids:
    its = sorted((r, v) for (r, i), v in items.items() if i == oid)
    var = collections.OrderedDict()               # exact raw sig -> rounds
    for r, (n, sig) in its: var.setdefault(mask(sig), []).append(r)
    reps = list(var)
    # families: single-link at 0.6 over masked sigs
    fams = []
    for sg in reps:
        for f in fams:
            if sim(sg, f[0]) >= 0.6: f.append(sg); break
        else: fams.append([sg])
    def zones(rs):
        d = collections.defaultdict(list)
        for r in rs: d[r[1]].append(r[2:])
        return ' '.join(f"Z{z}:{'/'.join(sorted(v))}" for z, v in sorted(d.items()))
    name = collections.Counter(n for _, (n, _) in its).most_common(1)[0][0]
    out.append(f"ID {oid:02X}   ({name})   {len(its)} rounds, {len(reps)} variants, {len(fams)} families")
    for fi, f in enumerate(fams):
        base = f[0]
        for vi, sg in enumerate(f):
            if vi == 0: kind = 'base'
            else:
                ms = sim(sg, base)
                kind = 'minor' if ms >= .9 else ('moderate' if ms >= .6 else 'different')
                kind += f" {ms:.0%}"
            out.append(f"   F{fi}.{vi:<2} {len(sg):>4} lines  {kind:<16} ; {zones(var[sg])}")
            stat[kind.split()[0]] += 1
        if fi == 0: pass
    stat['ids'] += 1; stat['multi-family-ids'] += (len(fams) > 1)
out.append(''); out.append(f"summary: {dict(stat)}")
open('object_families.txt', 'w').write('\n'.join(out) + '\n'); print('\n'.join(out[-1:]))
