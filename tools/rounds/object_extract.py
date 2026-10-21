#!/usr/bin/env python3
"""Extracts the code of every object of the global pool (object_pool.txt) from its representative round
(first round in order of appearance) into src/Level/_Objects/Global/Obj_<NEWID>.asm.
Auto labels (Obj05_2069EC, loc_208B3E ...) get the prefix P<NEWID>_ so they never clash. Identifiers that are neither
defined in the closure nor symbols of the current build (src/MD Port/Main.lst) are listed in extract_report.txt.
usage (repo root): python3 tools/rounds/object_extract.py [--write]"""
import sys, os, re, json, collections
sys.path.insert(0, 'tools/rounds'); os.environ.setdefault('CCZ', '/home/claude/work/mdport/src/Level/')
import rlib
WRITE = '--write' in sys.argv
remap = json.load(open('tools/rounds/object_remap.json'))
pool = {}                                  # newid -> (oldid, label, first round)
for l in open('tools/rounds/object_pool.txt'):
    m = re.match(r'([0-9A-F]{2})\s+([0-9A-F]{2})\.F(\d+)\s+(\S+)\s+; \d+ rounds, first (\w+)', l)
    if m: pool[int(m[1], 16)] = (int(m[2], 16), m[4], m[5])
lst = open('src/MD Port/Main.lst', errors='replace').read()
syms = set(re.findall(r'^[0-9A-F]{8}\s+([A-Za-z_][\w.]*):', lst, re.M)) | set(re.findall(r'^\s*([A-Za-z_]\w*)\s+(?:equ|rs\.\w)', lst, re.M | re.I))
IDENT = re.compile(r'(?<![\w.$#])[A-Za-z_]\w*')
import glob
for f in glob.glob('src/**/*.inc', recursive=True) + glob.glob('src/**/*.asm', recursive=True):
    t = open(f, errors='replace').read()
    syms |= set(re.findall(r'^\s*([A-Za-z_]\w*)\s+(?:equ|rs\.\w|=|set)\b', t, re.M | re.I)) | set(re.findall(r'^([A-Za-z_]\w*):', t, re.M))
cache = {}
def load(r):
    if r not in cache:
        p = rlib.round_path(r, generated=False); by = {x.name: x for x in rlib.routines(p)}
        if 'ObjectIndex' not in by: by = {x.name: x for x in rlib.routines(rlib.round_path(r, generated=True))}
        cache[r] = by
    return cache[r]
report = []; stat = collections.Counter(); os.makedirs('src/Level/_Objects/Global', exist_ok=True)
for nid, (oid, label, r) in sorted(pool.items()):
    by = load(r)
    tg = [m[1] for l in by['ObjectIndex'].lines for m in [re.match(r'\s*dc\.l\s+(\w+)', l)] if m]
    label = tg[oid - 1]; root = by.get(label)
    if root is None: stat['missing'] += 1; report.append(f"{nid:02X} {label} ({r}): root routine not found"); continue
    seen = {label}; todo = [label]; order = []
    while todo:
        n = todo.pop(0); x = by[n]; order.append(n)
        for l in x.lines:
            for w in IDENT.findall(l.split(';')[0]):
                z = by.get(w)
                if z and w not in seen and (rlib.AUTO.fullmatch(w) or w.startswith(label.split('_')[0]) or w not in syms):
                    seen.add(w); todo.append(w)
    own = {n for n in order}
    internal = {m[1] for n in order for l in by[n].lines for m in [re.match(r'^([A-Za-z_]\w*):', l)] if m} | own
    ren = lambda w: f"P{nid:02X}_{w}" if (rlib.AUTO.fullmatch(w) or re.fullmatch(r'(?:loc|locret)_[0-9A-Fa-f]+', w)) and w in internal else w
    body = []; unk = set(); raw = 0
    for n in order:
        for l in by[n].lines:
            code = l.split(';')[0]
            if re.match(r'\s*dc\.[wbl]\s', code) and rlib.LIT.search(code) is None and n != label: pass
            if re.match(r'\s*dc\.[wb]\s', code): raw += 1
            ops = re.sub(r'^\s*(?:[A-Za-z_]\w*:)?\s*[A-Za-z_.\w]+\s*', '', code, count=1)
            for w in IDENT.findall(ops):
                if w not in internal and w not in syms and not re.fullmatch(r'[dap]\d|sp|sr|ccr|usp|pc|[a-z]{1,4}', w) and not re.fullmatch(r'\w+\.[bwl]', w): unk.add(w)
            body.append(IDENT.sub(lambda m: ren(m.group(0)), l))
    stat['ok'] += 1; stat['raw'] += raw > 0; stat['unk'] += bool(unk)
    report.append(f"{nid:02X} {label} ({r}) {len(body)} lines raw_lines={raw} unresolved={sorted(unk)[:12]}")
    if WRITE: open(f'src/Level/_Objects/Global/Obj_{nid:02X}.asm', 'w').write(f"; Object ${nid:02X} - {label} (from {r}, old ID ${oid:02X})\n" + '\n'.join(body) + '\n')
open('tools/rounds/extract_report.txt', 'w').write('\n'.join(report) + f"\n{dict(stat)}\n"); print(dict(stat))
