"""Finds the fixed structure every round MMD shares: level data index, PLC lists, chunks, demo,
collision, layouts, object layouts, palette table, sound routine and Sub-CPU hooks."""
import re, struct

BASE = 0x200000
PLC_NAMES = ['PLC_Level', 'PLC_Std', 'PLC_Cam1_Full', 'PLC_Level', 'PLC_Cam2_Full', 'PLC_Cam3_Full', 'PLC_Cam4_Full',
             'PLC_Cam5_Full', 'PLC_Cam1_Incr', 'PLC_Cam2_Incr', 'PLC_Cam3_Incr', 'PLC_Cam4_Incr', 'PLC_Cam5_Incr',
             'PLC_Cam1_Full', 'PLC_Cam1_Full', 'PLC_Cam1_Full', 'PLC_Results', 'PLC_Cam1_Full', 'PLC_Signpost']


def u16(d, a, base=BASE):
    return struct.unpack('>H', d[a - base:a - base + 2])[0]


def u32(d, a, base=BASE):
    return struct.unpack('>I', d[a - base:a - base + 4])[0]


def is_color_block(b):
    return len(b) >= 4 and len(b) % 2 == 0 and all((struct.unpack('>H', b[i:i + 2])[0] & 0xF111) == 0 for i in range(0, len(b), 2))


def detect(d, ana, names, defs_sym=None, base=BASE):
    end = base + len(d)
    S = {'ldi': ana.ldi}
    ldi = ana.ldi
    if ldi is None:
        raise RuntimeError('level data index not found: not a Sonic CD round MMD?')
    S['art'] = u32(d, ldi) & 0xFFFFFF
    S['blocks'] = u32(d, ldi + 4) & 0xFFFFFF
    S['chunks'] = u32(d, ldi + 8)
    S['pal_ids'] = (d[ldi - base + 12], d[ldi - base + 13], d[ldi - base + 14], d[ldi - base + 15])
    # PLC lists: 19 word offsets right after the index
    pl = ldi + 0x10
    first = u16(d, pl)
    n = first // 2
    ok = first % 2 == 0 and 8 <= n <= 24
    offs = struct.unpack('>%dH' % n, d[pl - base:pl - base + 2 * n]) if ok else None
    ok = ok and all(first <= o < 0x800 and o % 2 == 0 for o in offs) and offs[1] > offs[0]
    S['plc'] = pl if ok else None
    S['plc_offs'] = offs if ok else None
    # demo
    rel = (defs_sym or {}).get('DemoDataRel', 0x6C00)
    S['demo'] = S['chunks'] + rel
    # collision: >=4 identical consecutive longs
    S['collision'] = None
    o = 0x100
    while o < len(d) - 32:
        v = struct.unpack('>4I', d[o:o + 16])
        if v[0] == v[1] == v[2] == v[3] and base + 0x10000 <= v[0] < end and v[0] & 1 == 0 and \
                struct.unpack('>8I', d[o:o + 32]).count(v[0]) == 8:
            S['collision'] = v[0]; S['collision_tbl'] = base + o; break
        o += 2
    # candidate addresses referenced by code
    refs = set()
    for a, (sz, m, op) in ana.code.items():
        for mo in re.finditer(r'#\$(2[0-3][0-9a-f]{4})\b|\$(2[0-3][0-9a-f]{4})\.l', op):
            refs.add(int(mo.group(1) or mo.group(2), 16))
    # layouts: 36-word header starting with 0x48, the three FG/BG/.. groups equal
    S['layouts'] = None
    for r in sorted(refs):
        if r + 72 <= end:
            w = struct.unpack('>36H', d[r - base:r - base + 72])
            if w[0] == 0x48 and w[:12] == w[12:24] == w[24:36] and all(0x48 <= x < 0x8000 and x % 2 == 0 for x in w):
                S['layouts'] = r; break
    # object layouts: dc.w .Layout-X, .Null-X ; dc.w $FFFF,0,0,0
    S['objlayouts'] = None
    for r in sorted(refs):
        if r + 16 <= end and u16(d, r) == 0x000C and u16(d, r + 4) == 0xFFFF and u16(d, r + 2) > 0x20:
            S['objlayouts'] = r; break
    # palette table: named by the reference or 'lea X.l,a1' just before the lsl #3 loader
    S['paltable'] = None
    for a, nm in names.items():
        if nm == 'PaletteTable':
            S['paltable'] = a
    # sound / Sub-CPU command routine and GATEARRAY writes
    srt = None
    ad = sorted(ana.code)
    for i, a in enumerate(ad[:-1]):
        sz, m, op = ana.code[a]
        if m == 'move.w' and op.replace(' ', '') == '#$e,d0':
            n = a + sz
            if n in ana.code and ana.code[n][1] == 'cmpi.w' and ana.code[n][2].replace(' ', '').startswith('#$67,d0'):
                srt = a; break
    S['sub_cmd'] = srt
    S['sub_cmd_end'] = None
    if srt:
        last = None
        for a in ad:
            if a >= srt and re.search(r'\$a12020\.l', ana.code[a][2]):
                last = a
            if last and a > last and ana.code[a][1] == 'rts':
                nxt = [x for x in ad if x > a]
                S['sub_cmd_end'] = nxt[0] if nxt else a + 2
                break
    S['ga_writes'] = [a for a, (sz, m, op) in ana.code.items()
                      if re.search(r'\$a1200[0-9a-f]\.l', op) and not (srt and srt <= a < (S['sub_cmd_end'] or 0))]
    return S
