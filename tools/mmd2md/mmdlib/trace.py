"""Recursive-descent code/data classifier for Sonic CD round MMDs (loaded at $200000).

Usage (library):  a = Analysis(open(mmd,'rb').read()); a.run()
Results: a.code {addr: (size, mnemonic, ops)}, a.tabs {addr: (kind, n, targets, end)}, a.ldi (level data index)
"""
import re, struct, sys
from capstone import Cs, CS_ARCH_M68K, CS_MODE_M68K_000

BASE = 0x200000
BADOPS = {'illegal', 'reset', 'trap', 'trapv', 'stop', 'chk', 'tas', 'bkpt', 'rtr'}
STUBS = (0x200100, 0x200106, 0x20010c, 0x200112)      # JmpTo_Start / Error / HInt / VInt


def tgt(t):
    m = re.fullmatch(r'\$([0-9a-f]+)(?:\.[lw])?', t.strip())
    return int(m.group(1), 16) if m else None


def find_ldi(d, base=BASE):
    """Level data index: dc.l $3000000|Art, $2000000|Blocks, Chunks (all inside the MMD)."""
    end = base + len(d)
    hits = []
    for o in range(0x100, len(d) - 12, 2):
        a, b, c = struct.unpack('>3I', d[o:o + 12])
        if a >> 24 == 3 and b >> 24 == 2 and (c >> 24) == 0 and \
                base <= (a & 0xFFFFFF) < end and base <= (b & 0xFFFFFF) < end and base <= c < end:
            hits.append(base + o)
    return hits[0] if len(hits) == 1 else (hits[0] if hits else None)


class Analysis:
    def __init__(self, data, base=BASE):
        self.d = data
        self.base = base
        self.end = base + len(data)
        self.md = Cs(CS_ARCH_M68K, CS_MODE_M68K_000)
        self.md.detail = True
        self.code = {}
        self.tabs = {}
        self.ptrmask = set()
        self.ldi = find_ldi(data, base)
        self.code_limit = self.ldi if self.ldi else self.end
        self.log = []

    # ----------------------------------------------------------------- decode
    def dec(self, a):
        o = a - self.base
        d = self.d
        if o < 0 or o + 2 > len(d) or o & 1:
            return None
        r = list(self.md.disasm(d[o:o + 12], a, 1))
        if not r:
            return None
        try:
            r[0].groups
        except Exception:
            return None
        return r[0]

    # ------------------------------------------------------------------ trace
    def trace(self, roots, spec):
        """Returns (newcode, newtabs) or None when a speculative trace is implausible."""
        d, base, end = self.d, self.base, self.end
        code, tabs = self.code, self.tabs
        new = {}; nt = {}; q = list(roots); n = 0
        while q:
            a = q.pop()
            while True:
                if a in code or a in new:
                    break
                if not (base + 0x100 <= a < self.code_limit) or a & 1:
                    if spec:
                        return None
                    break
                i = self.dec(a)
                if i and ('invalid' in i.op_str or (i.mnemonic == 'ori.b' and i.op_str == '#$0, d0')):
                    i = None
                if not i or (spec and (i.mnemonic in BADOPS or (a == roots[0] and i.mnemonic.startswith('ori'))
                                       or a in self.ptrmask)):
                    if spec:
                        return None
                    break
                new[a] = i; n += 1; m = i.mnemonic; ops = i.op_str
                if i.groups and 7 in i.groups and re.match(r'(b|db)[a-z]{1,2}(\.[bw])?$', m):
                    t = tgt(ops.split(',')[-1])
                    if t is None or not (base + 0x100 <= t < end):
                        if spec:
                            return None
                    else:
                        q.append(t)
                    if m.startswith('bra'):
                        break
                elif m in ('jmp', 'jsr'):
                    t = tgt(ops)
                    if t is not None:
                        if base + 0x100 <= t < end:
                            q.append(t)
                        elif spec:
                            return None
                    else:
                        mo = re.match(r'\$([0-9a-f]+)\(pc, [ad][0-7]\.[wl]\)$', ops)
                        if mo:
                            T = int(mo.group(1), 16); o = T - base
                            if T not in tabs and T not in nt:
                                if d[o] == 0x60:
                                    ent = []; k = T
                                    while d[k - base] == 0x60:
                                        ii = self.dec(k)
                                        if not ii or not ii.mnemonic.startswith('bra'):
                                            break
                                        ent.append(k); k += ii.size
                                    nt[T] = ('bra', len(ent), ent, k); q += ent
                                else:
                                    offs = []; k = o; lim = 1 << 30
                                    while k < o + lim and k + 2 <= len(d):
                                        w = struct.unpack('>h', d[k:k + 2])[0]
                                        if w <= 0 or w + o >= len(d) or w & 1:
                                            break
                                        offs.append(w); lim = min(lim, min(offs)); k += 2
                                    if not offs and spec:
                                        return None
                                    nt[T] = ('word', len(offs), [T + w for w in offs], T + 2 * len(offs))
                                    q += [T + w for w in offs]
                    if m == 'jmp':
                        break
                elif m == 'rts' or m == 'rte':
                    break
                a += i.size
        if spec and n < 2:
            return None
        return new, nt

    def commit(self, r):
        self.code.update(r[0]); self.tabs.update(r[1])

    # ------------------------------------------------------------- heuristics
    def imm_sources(self):
        c = set()
        for a, i in self.code.items():
            for mo in re.finditer(r'#\$(2[0-3][0-9a-f]{4})\b', i.op_str):
                c.add(int(mo.group(1), 16))
            if i.mnemonic not in ('jmp', 'jsr'):
                for mo in re.finditer(r'\$(2[0-3][0-9a-f]{4})\.l', i.op_str):
                    c.add(int(mo.group(1), 16))
                for mo in re.finditer(r'\$([0-9a-f]+)\(pc\)', i.op_str):
                    c.add(int(mo.group(1), 16))
        return c

    def ptr_runs(self, minn=6):
        d, base, end = self.d, self.base, self.end
        o = 0; runs = []
        while o < len(d) - 4:
            k = o; n = 0
            while k + 4 <= len(d):
                v = struct.unpack('>I', d[k:k + 4])[0]
                if base + 0x100 <= v < end and v & 1 == 0:
                    n += 1; k += 4
                else:
                    break
            if n >= minn:
                runs.append((o, n)); o = k
            else:
                o += 2
        return runs

    def gaps(self):
        cov = bytearray(len(self.d))
        for a, i in self.code.items():
            for k in range(i.size):
                cov[a - self.base + k] = 1
        for T, (kind, n, ent, e) in self.tabs.items():
            for k in range(T - self.base, e - self.base):
                cov[k] = 1
        g = []; s0 = None
        for k, c in enumerate(cov):
            if not c and s0 is None:
                s0 = k
            if c and s0 is not None:
                g.append((s0, k)); s0 = None
        if s0 is not None:
            g.append((s0, len(self.d)))
        return g

    def run(self):
        d, base, end = self.d, self.base, self.end
        for _o, _n in self.ptr_runs():
            for _k in range(_o, _o + 4 * _n):
                self.ptrmask.add(base + _k)
        hdr = [struct.unpack('>I', d[o:o + 4])[0] for o in (8, 12, 16)] + list(STUBS)
        self.commit(self.trace(hdr, False))
        tried = set(); log = []
        for rnd in range(1, 20):
            cands = self.imm_sources()
            for o, n in self.ptr_runs():
                for j in range(n):
                    cands.add(struct.unpack('>I', d[o + 4 * j:o + 4 * j + 4])[0])
            for t in list(cands):
                k = t
                while base <= k < end - 4:
                    v = struct.unpack('>I', d[k - base:k - base + 4])[0]
                    if base + 0x100 <= v < end and v & 1 == 0 and k not in self.code:
                        cands.add(v); k += 4
                    else:
                        break
            add = 0
            for t in sorted(cands):
                if t in tried or t in self.code or t & 1:
                    continue
                tried.add(t)
                r = self.trace([t], True)
                if r:
                    self.commit(r); add += len(r[0])
            log.append(add)
            if not add:
                break
        for _ in range(10):
            add = 0
            for s0, e0 in self.gaps():
                a = base + s0
                if a < base + 0x100 or a >= self.code_limit or e0 - s0 < 6:
                    continue
                r = self.trace([a], True)
                if r:
                    self.commit(r); add += len(r[0])
            log.append(('gapstart', add))
            if not add:
                break
        self.log = log
        # keep plain tuples (also what gets pickled)
        self.code = {a: (i.size, i.mnemonic, i.op_str) if not isinstance(i, tuple) else i for a, i in self.code.items()}
        return self
