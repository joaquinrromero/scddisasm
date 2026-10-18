"""Orchestration: analyse -> name -> emit -> assemble -> byte-compare, plus the MD build."""
import glob, hashlib, json, os, re, shutil, subprocess, sys, time

from . import defs as defsmod, emit as emitmod, levelstruct, refnames
from .trace import Analysis, BASE

ZONES = ['Palmtree Panic', 'Collision Chaos', 'Tidal Tempest', 'Quartz Quadrant', 'Wacky Workbench',
         'Stardust Speedway', 'Metallic Madness']
ZONE_ABBR = ['PPZ', 'CCZ', 'TTZ', 'QQZ', 'WWZ', 'SSZ', 'MMZ']
ROUND_TO_ZONE = {1: 0, 3: 1, 4: 2, 5: 3, 6: 4, 7: 5, 8: 6}
TIMES = {'A': ('Present', 1), 'B': ('Past', 0), 'C': ('Good Future', 2), 'D': ('Bad Future', 2)}


def parse_name(path):
    """R31A__.MMD / R11C.MMD / DEMO11A.MMD -> dict(zone_idx, act, time) or None."""
    b = os.path.basename(path).upper()
    m = re.match(r'(?:R|DEMO)(\d)(\d)([A-D])', b)
    if not m:
        return None
    rnd, act, t = int(m.group(1)), int(m.group(2)), m.group(3)
    z = ROUND_TO_ZONE.get(rnd)
    if z is None:
        return None
    return {'round': rnd, 'zone': z, 'act': act, 'time': t, 'id': 'R%d%d%s' % (rnd, act, t)}


def shared_files(src):
    """sha1 -> path (relative to src) of data files that are common to every zone."""
    out = {}
    pats = ['Level/_Data/*.bin', 'Level/_Objects/*/Data/*.bin', 'Level/_Objects/*/Data/*.nem']
    for p in pats:
        for f in glob.glob(os.path.join(src, p)):
            data = open(f, 'rb').read()
            if len(data) >= 16:
                out.setdefault(hashlib.sha1(data).hexdigest(), os.path.relpath(f, src).replace('\\', '/'))
    return out


def asm68k(repo, asmfile, out, flags=(), lst=None):
    exe = os.path.abspath(os.path.join(repo, 'bin', 'asm68k.exe'))
    src = os.path.join(repo, 'src')
    arg = asmfile.replace('/', '\\') + ',' + os.path.abspath(out) + ',,' + (os.path.abspath(lst) if lst else '')
    cmd = [exe, '/p', '/o', 'ae-,l.,ow+', '/e', 'REGION=1', '/e', 'DEMO=0'] + list(flags) + [arg]
    if os.name != 'nt':
        cmd = ['wine'] + cmd
    env = dict(os.environ); env.setdefault('WINEDEBUG', '-all')
    if os.path.exists(out):
        os.remove(out)
    r = subprocess.run(cmd, cwd=src, env=env, capture_output=True, text=True)
    return r.stdout + r.stderr


def build_names(d, ana, refctx):
    """refctx: dict(code, data, syms, ids). Returns (names {addr:name}, blobs)."""
    nm, blobs = refnames.name_all(ana.code, d, refctx['code'], refctx['data'], refctx['syms'], refctx['ids'])
    return refnames.clean(nm), blobs


def load_reference(repo, cache):
    mmd, syms = refnames.build_reference(repo, cache)
    data = open(mmd, 'rb').read()
    ana = Analysis(data).run()
    return {'code': ana.code, 'data': data, 'syms': syms, 'ids': refnames.harvest_ids(os.path.join(repo, 'src'))}


def write_files(src, files, asm, asm_path):
    for p, b in files.items():
        fp = os.path.join(src, p)
        os.makedirs(os.path.dirname(fp), exist_ok=True)
        open(fp, 'wb').write(b)
    os.makedirs(os.path.dirname(os.path.join(src, asm_path)), exist_ok=True)
    open(os.path.join(src, asm_path), 'w').write(asm)


def roundtrip(repo, d, ana, names, blobs, S, dfs, opts, asm_path, max_iter=40, log=print, tag='rt'):
    """Emit + assemble (non-MD build) until the result is byte-identical to the MMD.
    Instructions asm68k cannot reproduce are emitted as raw bytes. Returns (ok, raw, asm, files, info)."""
    src = os.path.join(repo, 'src')
    raw = set()
    tmp = os.path.join(repo, 'out', 'misc', 'roundtrip_%s.bin' % tag)
    os.makedirs(os.path.dirname(tmp), exist_ok=True)
    for it in range(max_iter):
        asm, files, info = emitmod.emit(d, ana, names, blobs, S, dfs, opts, raw)
        write_files(src, files, asm, asm_path)
        out = asm68k(repo, asm_path, tmp)
        errs = [l for l in out.splitlines() if re.search(r'\bError\b', l)]
        if not os.path.exists(tmp) or errs:
            bad = set()
            for l in errs:
                m = re.search(r'\((\d+)\)\s*:\s*Error', l)
                if m:
                    bad.add(int(m.group(1)))
            # map assembler lines back to instructions
            lines = asm.split('\n')
            added = 0
            for ln in bad:
                addr = info['linemap'].get(ln)
                if addr is not None and addr not in raw:
                    raw.add(addr); added += 1
            log('  iter %d: %d assembler errors -> %d raw' % (it, len(errs), added))
            if not added:
                log('\n'.join(errs[:10]))
                return False, raw, asm, files, info
            continue
        a = open(tmp, 'rb').read()
        if a == d:
            return True, raw, asm, files, info
        n = min(len(a), len(d))
        k = next((i for i in range(n) if a[i] != d[i]), n)
        addr = BASE + k
        item = next((it_ for it_ in info['order'] if it_[0] <= addr < it_[0] + it_[1]), None)
        log('  iter %d: first diff at $%X (%s) size %d/%d' % (it, addr, item[2] if item else '?', len(a), len(d)))
        if item and item[2] == 'code' and item[0] not in raw:
            raw.add(item[0]); continue
        return False, raw, asm, files, info
    return False, raw, asm, files, info


# ---------------------------------------------------------------------------- data store
class Store:
    """Keeps the data files of one zone folder unique: identical content is written once."""

    def __init__(self, src, zone_dir):
        self.src = src
        self.by_sha = {}
        self.by_path = {}
        root = os.path.join(src, zone_dir, 'Data')
        for sub in ('Art', 'Level', 'Collision', 'Objects', 'Palette', 'Mappings', 'Animations', 'Misc'):
            for f in glob.glob(os.path.join(root, sub, '*')):
                data = open(f, 'rb').read()
                rel = os.path.relpath(f, src).replace('\\', '/')
                sha = hashlib.sha1(data).hexdigest()
                self.by_sha.setdefault(sha, rel); self.by_path[rel] = sha

    def path_for(self, dd, sub, fname, data, act):
        sha = hashlib.sha1(data).hexdigest()
        if sha in self.by_sha:
            return self.by_sha[sha]
        stem, ext = os.path.splitext(fname)
        cand = '%s/%s/%s' % (dd, sub, fname)
        if cand in self.by_path and self.by_path[cand] != sha:
            cand = '%s/%s/%s (%s)%s' % (dd, sub, stem, act, ext)
            k = 2
            while cand in self.by_path and self.by_path[cand] != sha:
                cand = '%s/%s/%s (%s %d)%s' % (dd, sub, stem, act, k, ext); k += 1
        self.by_sha[sha] = cand; self.by_path[cand] = sha
        return cand


# ---------------------------------------------------------------------------- ROM variables
WRITERS = {'move', 'clr', 'add', 'addi', 'addq', 'sub', 'subi', 'subq', 'bset', 'bclr', 'bchg', 'neg', 'not', 'eor',
           'eori', 'or', 'ori', 'and', 'andi', 'asl', 'asr', 'lsl', 'lsr', 'rol', 'ror', 'st', 'sf', 'tas', 'negx',
           'roxl', 'roxr', 'neg', 'addx', 'subx', 'movem'}


def find_romvars(ana, d):
    """Absolute-long writes into the MMD's own address range (self-modifying data the cartridge cannot hold).
    Returns {base: (size, [member addresses])}. Writes through pointers/PC-relative are found by emulation only."""
    end = BASE + len(d)
    w = {}
    for a, (sz, m, o) in ana.code.items():
        base = re.sub(r'\.[bwls]$', '', m)
        if base not in WRITERS:
            continue
        last = o.split(',')[-1].strip()
        mo = re.fullmatch(r'\$(2[0-3][0-9a-f]{4})\.l', last)
        if mo and (',' in o or base in ('clr', 'st', 'sf', 'tas', 'neg', 'not', 'negx')):
            v = int(mo.group(1), 16)
            size = {'b': 1, 'w': 2, 'l': 4}.get(m[-1], 2) if '.' in m else 2
            w[v] = max(w.get(v, 0), size)
        if base in ('bset', 'bclr', 'bchg') and mo:
            w[int(mo.group(1), 16)] = max(w.get(int(mo.group(1), 16), 0), 1)
    # also variables that are *read* by address and overlap a written one (e.g. long written, word read)
    for a, (sz, m, o) in ana.code.items():
        for mo in re.finditer(r'\$(2[0-3][0-9a-f]{4})\.l', o):
            v = int(mo.group(1), 16)
            for b in list(w):
                if b < v < b + w[b]:
                    pass
    groups = {}
    cur = None
    for v in sorted(w):
        if cur and v < cur[0] + cur[1]:
            cur[1] = max(cur[1], v + w[v] - cur[0]); cur[2].append(v)
        else:
            cur = [v, w[v], [v]]; groups[v] = cur
    out = {}
    for b, (base, size, members) in groups.items():
        # include read-only aliases of the group (same bytes accessed with other sizes/offsets)
        mem = set(members)
        for a, (sz, m, o) in ana.code.items():
            for mo in re.finditer(r'\$(2[0-3][0-9a-f]{4})\.l', o):
                v = int(mo.group(1), 16)
                if base <= v < base + size:
                    mem.add(v)
        out[base] = (size, sorted(mem))
    return out
