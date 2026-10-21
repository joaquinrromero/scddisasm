#!/usr/bin/env python3
"""One source file per pool object (object_pool.txt) taken from the first round that uses it.
Every auto-named label of the object's closure (code + its Data_ blobs) is renamed to <Name>_<n>; literal $2xxxxx
pointers are turned into labels with the round's address map. Output: src/Level/_Objects/Pool/<NN> <Name>.asm"""
import sys, os, re, json, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); os.environ.setdefault('CCZ', '/home/claude/work/mdport/src/Level/')
import rlib
OUT = os.environ.get('OUT', '../../src/Level/_Objects/Pool'); os.makedirs(OUT, exist_ok=True)
remap = json.load(open('object_remap.json'))
pool = {}                                              # newid -> (round, oldid, label)
for l in open('object_pool.txt'):
    m = re.match(r'([0-9A-F]{2})\s+([0-9A-F]{2})\.F(\d+)\s+(\S+)\s+; \d+ rounds, first (R\w+)', l)
    if m: pool[int(m[1], 16)] = (m[5], int(m[2], 16), m[4])
cache = {}
def load(r):
    if r in cache: return cache[r]
    p = rlib.round_path(r, generated=False); by = {x.name: x for x in rlib.routines(p)}
    if 'ObjectIndex' not in by: by = {x.name: x for x in rlib.routines(rlib.round_path(r, generated=True))}
    cache[r] = (by, rlib.address_map(r)); return cache[r]
stats = collections.Counter()
for nid, (r, oid, lab) in sorted(pool.items()):
    by, amap = load(r)
    tg = [m[1] for l in by['ObjectIndex'].lines for m in [re.match(r'\s*dc\.l\s+(\w+)', l)] if m]
    if oid - 1 >= len(tg) or tg[oid - 1] not in by: stats['missing'] += 1; continue
    root = tg[oid - 1]; seen = [root]; todo = [root]
    import bisect
    ad = sorted((a, n) for n, a in amap.items() if n in by); adk = [a for a, _ in ad]
    def owner(a):
        i = bisect.bisect_right(adk, a) - 1
        if i < 0: return None
        n = ad[i][1]
        return (n, a - ad[i][0]) if a - ad[i][0] < 0x4000 else None
    while todo:
        y = by[todo.pop()]
        for ln in y.lines:
            for m in rlib.LIT.finditer(ln.split(';')[0]):
                o = owner(int(m[0][1:], 16))
                if o and o[0] not in seen and rlib.AUTO.fullmatch(o[0]): seen.append(o[0]); todo.append(o[0])
            for w in re.findall(r'[A-Za-z_]\w*', ln.split(';')[0]):
                z = by.get(w)
                if z and w not in seen and (rlib.AUTO.fullmatch(w) or w.startswith(root.split('_')[0])): seen.append(w); todo.append(w)
    name = re.sub(r'^Obj(?=[A-Z])', '', root) if not rlib.AUTO.fullmatch(root) else f"Obj{nid:02X}"
    base = f"Obj{nid:02X}_{name}" if not name.startswith('Obj') else name
    ren = {n: (f"{base}" if n == root else f"{base}_{k}") for k, n in enumerate(seen)}
    inv = {a: n for n, a in amap.items()}
    text = []
    for n in seen:
        for ln in by[n].lines:
            ln = re.sub(r'[A-Za-z_]\w*', lambda m: ren.get(m[0], m[0]), ln)
            def lit(m):
                a = int(m[0][1:], 16)
                o = owner(a)
                if o and o[0] in ren: return ren[o[0]] + (f"+${o[1]:X}" if o[1] else '')
                stats['unresolved_lit'] += 1; return m[0] + ' /*UNRESOLVED*/'
            ln = rlib.LIT.sub(lit, ln); text.append(ln)
    hdr = f"; Pool object ${nid:02X} (old ID ${oid:02X}) - taken from {r}\n"
    open(f"{OUT}/{nid:02X} {base}.asm", 'w').write(hdr + '\n'.join(text) + '\n'); stats['files'] += 1
print(dict(stats))
