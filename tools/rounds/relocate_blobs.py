#!/usr/bin/env python3
"""
Relocate raw code blobs (labels followed by dc.w/dc.b) of an extracted round (MD Port/Zones/<R>.asm).

The decompiler leaves some routines as raw bytes; their absolute operands ($20xxxx = Word RAM addresses of the
Sega CD) are meaningless in the Mega Drive ROM. The bytes are kept exactly (instructions are found with
capstone only to know where the operands are) and every 32-bit field that points inside the round becomes
`dc.l label+offset`.

usage (from the repo root):  python3 tools/rounds/relocate_blobs.py R12A [label ...]
needs: tools/<R>__.MMD (retail), an asm68k listing of the current build (src/MD Port/Main.lst) and the round's
own build listing (rlib.address_map).
"""
import sys, re, os, bisect, struct
sys.path.insert(0, os.path.dirname(__file__))
os.environ.setdefault("CCZ", "/home/claude/work/mdport/src/Level/")
import rlib
from capstone import Cs, CS_ARCH_M68K, CS_MODE_BIG_ENDIAN, CS_MODE_M68K_000

RND = sys.argv[1]; ONLY = set(sys.argv[2:])
MMD = open(f"{os.environ.get('MMDDIR','/home/claude/work/mdport/tools')}/{RND}__.MMD", "rb").read()
amap = rlib.address_map(RND, os.environ.get("RSRC", "/home/claude/work/mdport/src"))
items = sorted((v, k) for k, v in amap.items())
lst = open("src/MD Port/Main.lst", errors="replace").read()
syms = set(re.findall(r'^[0-9A-F]{8}\s+([A-Za-z_][\w.]*):', lst, re.M))
f = f"src/MD Port/Zones/{RND}.asm"; lines = open(f).read().split("\n")
md = Cs(CS_ARCH_M68K, CS_MODE_BIG_ENDIAN | CS_MODE_M68K_000)

def label(t):
    k = bisect.bisect_right(items, (t, "~")) - 1
    while k >= 0:
        a, n = items[k]
        if t - a > 0x2000: break
        for c in (f"{RND}_{n}", n):
            if c in syms: return c + (f"+${t-a:X}" if t != a else "")
        k -= 1
    return None

def parse(l):
    m = re.match(r'^\s*dc\.([wb])\s+(.*?)\s*(;.*)?$', l)
    if not m: return None
    out = bytearray()
    for v in m.group(2).split(","):
        v = int(v.strip().lstrip("$"), 16)
        out += v.to_bytes(2 if m.group(1) == "w" else 1, "big")
    return out

i = 0; out = []; done = []
while i < len(lines):
    m = re.match(rf'^{RND}_(\w+?)_([0-9A-F]{{6}}):\s*$', lines[i])
    if not m or (ONLY and f"{RND}_{m.group(1)}_{m.group(2)}" not in ONLY):
        out.append(lines[i]); i += 1; continue
    addr = int(m.group(2), 16); j = i + 1; data = bytearray(); src = []
    while j < len(lines):
        p = parse(lines[j])
        if p is None:
            if lines[j].strip() == "" or lines[j].strip() == "even": j += 1; continue
            break
        data += p; j += 1
    off = addr - 0x200000
    if bytes(data) != MMD[off:off + len(data)] or not data:
        out.append(lines[i]); i += 1; continue          # not a verbatim blob
    # find 32-bit pointers: capstone to know instruction extents, then scan operands
    fields = {}
    pos = 0
    while pos < len(data):
        ins = list(md.disasm(bytes(data[pos:pos + 12]), addr + pos, 1))
        if not ins: pos += 2; continue
        sz = ins[0].size
        for q in range(pos + 2, pos + sz - 3, 2):
            v = struct.unpack(">I", data[q:q + 4])[0]
            if 0x200000 <= v < 0x240000 and q not in fields and label(v): fields[q] = v
        pos += sz
    # also pointer tables (aligned longs in data)
    res = []; q = 0
    while q < len(data):
        if q in fields:
            res.append(f"\tdc.l\t{label(fields[q])}"); q += 4
        else:
            res.append(f"\tdc.w\t${struct.unpack('>H', data[q:q+2])[0]:04X}" if q + 1 < len(data) else f"\tdc.b\t${data[q]:02X}"); q += 2
    out.append(lines[i]); out += res; done.append((f"{RND}_{m.group(1)}_{m.group(2)}", len(fields)))
    i = j
open(f, "w").write("\n".join(out))
print(done)
