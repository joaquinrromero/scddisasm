#!/usr/bin/env python3
"""
Variation analysis over the 70 decompiled rounds (tools/mmd2md output): which ObjectIndex slots are the same
routine everywhere, which vary by zone, by act or by time zone. Signatures are the routine text with auto
labels / $2xxxxx literals normalised (rlib.norm), compared along fall-through-free bodies (up to the next label).
usage: CCZ=<src/Level/ of the generated tree> python3 analyze_variation.py
"""
import re, os, sys, glob, collections
sys.path.insert(0, os.path.dirname(__file__)); import rlib
ZN = rlib.ZN; TN = rlib.TN
rows = {}                                   # round -> list of routine sigs per slot
for z in ZN:
    for a in "123":
        for t in "ABCD":
            r = f"R{z}{a}{t}"; p = rlib.round_path(r, generated=False)
            if not os.path.exists(p): continue
            rs = rlib.routines(p); by = {x.name: x for x in rs}
            if "ObjectIndex" not in by: continue
            tgt = [m.group(1) for l in by["ObjectIndex"].lines for m in [re.match(r'\s*dc\.l\s+(\w+)', l)] if m]
            sig = []
            for n in tgt:
                x = by.get(n)
                sig.append(hash(x.sig[:40]) if x and len(x.sig) > 1 else ("N", n))
            rows[r] = (tgt, sig)
print(len(rows), "rounds with ObjectIndex")
nslots = max(len(v[0]) for v in rows.values())
print("slot  all-same  by-zone-only  by-act  by-time  other   (distinct signatures)")
cls = collections.Counter(); detail = {}
for s in range(nslots):
    ent = {r: v[1][s] for r, v in rows.items() if s < len(v[1])}
    if len(set(ent.values())) == 1: c = "same"
    else:
        ok = lambda key: all(len({ent[r] for r in ent if key(r) == k}) == 1 for k in {key(r) for r in ent})
        zone = lambda r: r[1]; za = lambda r: r[1:3]; zt = lambda r: (r[1], r[3])
        if ok(zone): c = "zone"
        elif ok(za): c = "zone+act"
        elif ok(zt): c = "zone+time"
        else: c = "other"
    cls[c] += 1; detail[s] = (c, len(set(ent.values())))
print(dict(cls))
print({hex(s): d for s, d in detail.items() if d[0] != "same"})
