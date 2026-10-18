"""Parses the repo's RAM / object-field definitions so absolute operands get their real names."""
import os, re


def parse(src):
    """src: path of the repo 'src' folder. Returns (sym, obj): all numeric symbols, object field offsets."""
    sym = {}; obj = {}

    def val(e):
        e = e.split(';')[0].strip()
        e = re.sub(r'\$([0-9a-fA-F]+)', r'0x\1', e)
        try:
            return eval(e, {}, dict(sym))
        except Exception:
            return None
    for f in ('_Include/Common.inc', '_Include/Main CPU.inc', '_Include/Main CPU Variables.inc', 'Level/_Definitions.inc'):
        rs = 0
        p = os.path.join(src, f)
        if not os.path.exists(p):
            continue
        lines = open(p, errors='ignore').read().splitlines()
        mode = None
        isl = f.startswith('Level')
        for ln in lines:
            m = re.match(r'^(\w+)\s+(?:equ|EQU|=)\s+(.+)$', ln.strip() if not ln[:1].isspace() else ln.strip())
            if m and not ln[:1].isspace():
                v = val(m.group(2))
                if v is not None:
                    sym[m.group(1)] = v
                continue
            s = ln.strip()
            if re.match(r'rsreset', s):
                rs = 0; continue
            m = re.match(r'rsset\s+(.+)', s)
            if m:
                v = val(m.group(1)); rs = v if v is not None else rs; mode = 'ram'; continue
            m = re.match(r'^(\w+)?\s*rs\.([bwl])\s+(.+)$', s)
            if m:
                name, sz, n = m.groups(); n = val(n)
                if n is None:
                    continue
                if sz != 'b' and rs % 2:
                    rs += 1
                if name:
                    sym[name] = rs
                    if mode != 'ram' and isl and name.startswith('o') and rs < 0x40:
                        obj[name] = rs
                rs += n * {'b': 1, 'w': 2, 'l': 4}[sz]
    return sym, obj


def ram_names(sym):
    rev = {}
    for k, v in sym.items():
        if isinstance(v, int):
            vv = v & 0xFFFFFFFF
            if vv >= 0xA00000 and vv not in rev:
                rev[vv] = k
    return rev
