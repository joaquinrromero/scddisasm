#!/usr/bin/env python3
"""Regenerates the PLC lists of an extracted round with real pointers (the decompiler leaves them as raw words).
usage (repo root): python3 tools/rounds/fix_plc.py R12B"""
import struct, bisect, re, sys, os
sys.path.insert(0, 'tools/rounds'); os.environ.setdefault('CCZ', '/home/claude/work/mdport/src/Level/')
import rlib
R = sys.argv[1]
m = rlib.address_map(R, '/home/claude/work/mdport/src')
items = sorted((v, k) for k, v in m.items())
d = open(f'/home/claude/work/mdport/tools/{R}__.MMD', 'rb').read()
syms = set(re.findall(r'^[0-9A-F]{8}\s+([A-Za-z_][\w.]*):', open('src/MD Port/Main.lst', errors='replace').read(), re.M))
f = f'src/MD Port/Zones/{R}.asm'; t = open(f).read()
own = set(re.findall(rf'^({R}_\w+):', t, re.M))
def lab(p):
    k = bisect.bisect_right(items, (p, '~')) - 1
    while k >= 0:
        a, n = items[k]
        if p - a > 0x4000: break
        for cand in (f'{R}_{n}', n):
            if cand in syms or cand in own: return cand + (f'+${p-a:X}' if p != a else '')
        k -= 1
    raise SystemExit(f'no symbol for {hex(p)}')
# the table itself: word offsets from PLCLists; every distinct target becomes a list
base = m['PLCLists'] - 0x200000
offs = []
k = 0
first = struct.unpack('>H', d[base:base + 2])[0]
cnt = first // 2
tbl = [struct.unpack('>H', d[base + 2 * x:base + 2 * x + 2])[0] for x in range(cnt)]
byaddr = {v: k for k, v in m.items() if k.startswith('PLC_')}
nm = {}
for o in sorted(set(tbl)):
    a = 0x200000 + base + o
    nm[o] = byaddr.get(a, f'PLC_Alt_{o:X}')
out = [f'{R}_PLCLists:'] + [f'\tdc.w\t{R}_{nm[o]}-{R}_PLCLists' for o in tbl] + ['']
for o in sorted(set(tbl)):
    x = base + o; n = struct.unpack('>H', d[x:x + 2])[0]
    out += [f'{R}_{nm[o]}:', f'\tdc.w\t${n:X}']
    for k in range(n + 1):
        p, v = struct.unpack('>LH', d[x + 2 + 6 * k:x + 8 + 6 * k]); out += [f'\tdc.l\t{lab(p)}', f'\tdc.w\t${v:X}']
    out.append('')
names = nm
i = t.index(f'{R}_PLCLists:'); j = t.index('\tincbin\t"Level/Palmtree Panic/Data/Level/Padding')
open(f, 'w').write(t[:i] + '\n'.join(out) + '\n' + t[j:])
print(R, 'PLC lists:', len(names))
