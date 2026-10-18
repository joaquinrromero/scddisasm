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


def roundtrip(repo, d, ana, names, blobs, S, dfs, opts, asm_path, max_iter=12, log=print):
    """Emit + assemble (non-MD build) until the result is byte-identical to the MMD.
    Instructions asm68k cannot reproduce are emitted as raw bytes. Returns (ok, raw, asm, files, info)."""
    src = os.path.join(repo, 'src')
    raw = set()
    tmp = os.path.join(repo, 'out', 'misc', 'roundtrip.bin')
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
