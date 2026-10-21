#!/usr/bin/env python3
"""Builds the global object ID pool from object_families.txt.
Family 0 of every old ID keeps its ID (objects identical across rounds stay the same number); every further
family (a different object that reused the ID in other zones) gets a fresh ID after the highest old one, in
order of first appearance. Output: object_remap.json {round: {oldID: newID}} and object_pool.txt."""
import re, json, collections
rounds = lambda s: [f"R{z}{r}" for z, rr in re.findall(r'Z(\d):(\S+)', s) for r in [None]] if False else None
def expand(s):
    out = []
    for z, rr in re.findall(r'Z(\d):(\S+)', s):
        for t in rr.split('/'): out.append(f"R{z}{t[0]}{t[1]}")
    return out
fam = []; cur = None
for l in open('object_families.txt'):
    m = re.match(r'ID ([0-9A-F]+)\s+\((\w+)\)', l)
    if m: cur = (int(m.group(1), 16), m.group(2)); continue
    m = re.match(r'\s+F(\d+)\.(\d+)\s+(\d+) lines\s+(base|minor \d+%|moderate \d+%|different \d+%)\s+; (.*)', l)
    if m: fam.append((cur[0], cur[1], int(m.group(1)), int(m.group(2)), expand(m.group(5))))
maxold = max(f[0] for f in fam)
famrounds = collections.defaultdict(list)           # (oldID, family) -> rounds
for oid, name, fi, vi, rs in fam: famrounds[(oid, fi)] += rs
fnames = {(o, fi): n for o, n, fi, vi, _ in fam}
order = sorted(famrounds, key=lambda k: (k[1] > 0, min(famrounds[k]) if k[1] > 0 else '', k[0]))
nxt = maxold + 1; newid = {}
for k in sorted(famrounds, key=lambda k: (k[1], min(famrounds[k]), k[0])):
    if k[1] == 0: newid[k] = k[0]
    else: newid[k] = nxt; nxt += 1
remap = collections.defaultdict(dict)
for k, rs in famrounds.items():
    for r in rs: remap[r][k[0]] = newid[k]
json.dump(remap, open('object_remap.json', 'w'), indent=0, sort_keys=True)
with open('object_pool.txt', 'w') as f:
    f.write(f"Global object pool: {len(newid)} objects (highest ID ${max(newid.values()):02X}; limit $FF).\nFamily 0 keeps its old ID; other families get new IDs.\nNEWID  old ID.family  label  rounds\n")
    for k in sorted(newid, key=lambda k: newid[k]):
        rs = sorted(famrounds[k]); f.write(f"{newid[k]:02X}  {k[0]:02X}.F{k[1]}  {fnames[k]}  ; {len(rs)} rounds, first {rs[0]}\n")
print(len(newid), hex(max(newid.values())))
