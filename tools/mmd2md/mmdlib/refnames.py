"""Names for an MMD obtained by comparing it against a reference build (e.g. R11A built from the repo)."""
import collections, glob, json, os, pickle, re, struct, subprocess, sys

W = 6          # window of identical (normalised) instructions used for matching


def run_wine(args, cwd, env=None):
    exe = args[0]
    cmd = [exe] + args[1:] if os.name == 'nt' else ['wine'] + args
    e = dict(os.environ); e.setdefault('WINEDEBUG', '-all'); e.update(env or {})
    return subprocess.run(cmd, cwd=cwd, env=e, capture_output=True, text=True)


def build_reference(repo, outdir, zone='Palmtree Panic', act='Act 1 Present', demo=0):
    """Assemble a repo level and dump its symbols. Returns (mmd_path, {addr: [names]})."""
    os.makedirs(outdir, exist_ok=True)
    src = os.path.join(repo, 'src')
    mmd = os.path.abspath(os.path.join(outdir, 'ref.MMD')); sym = os.path.abspath(os.path.join(outdir, 'ref.sym'))
    inc = os.path.abspath(os.path.join(outdir, 'ref_syms.inc'))
    if not os.path.exists(inc):
        asm = os.path.abspath(os.path.join(repo, 'bin', 'asm68k.exe'))
        r = run_wine([asm, '/p', '/o', 'ae-,l.,ow+', '/e', 'REGION=1', '/e', 'DEMO=%d' % demo,
                      'Level\\%s\\%s.asm' % (zone, act), ',', mmd, ',', sym][:0] or
                     [asm, '/p', '/o', 'ae-,l.,ow+', '/e', 'REGION=1', '/e', 'DEMO=%d' % demo,
                      'Level\\%s\\%s.asm,%s,%s' % (zone, act, mmd, sym)], cwd=src)
        if not os.path.exists(mmd):
            raise RuntimeError('reference build failed:\n' + r.stdout[-1500:])
        dump = os.path.abspath(os.path.join(repo, 'bin', 'dumpasmsym.exe'))
        run_wine([dump, '-m', 'asm', sym, '-o', inc], cwd=src)
    return mmd, load_syms(inc)


def load_syms(inc):
    sym = {}
    for ln in open(inc, errors='ignore'):
        m = re.match(r'(\w+)\s+equ\s+\$([0-9A-Fa-f]+)', ln)
        if m:
            sym.setdefault(int(m.group(2), 16), []).append(m.group(1))
    return sym


def harvest_ids(src):
    ids = {}
    for f in glob.glob(os.path.join(src, '**', '*.*'), recursive=True):
        if f.endswith(('.asm', '.inc', '.i')):
            for t in re.findall(r'[A-Za-z_][A-Za-z0-9_.]*', open(f, errors='ignore').read()):
                if t.lower() not in ids or (t != t.lower() and ids[t.lower()] == t.lower()):
                    ids[t.lower()] = t
    return ids


def norm(m, o):
    o = re.sub(r'\$2[0-3][0-9a-f]{4}(\.l)?', 'A', o)
    o = re.sub(r'\$[0-9a-f]+\(pc', 'P(pc', o)
    if re.match(r'(b[a-z]{1,2}|db[a-z]{1,2})(\.[bw])?$', m):
        o = re.sub(r'\$[0-9a-f]+$', 'A', o)
    return m + ' ' + o


def seqs(C):
    runs = []; cur = []
    for a in sorted(C):
        if cur and cur[-1] + C[cur[-1]][0] == a:
            cur.append(a)
        else:
            if cur:
                runs.append(cur)
            cur = [a]
    if cur:
        runs.append(cur)
    return runs


def match_code(A, B):
    """A, B: {addr: (size, mnem, ops)}. Returns {addrA: addrB}."""
    NA = {a: norm(A[a][1], A[a][2]) for a in A}; NB = {a: norm(B[a][1], B[a][2]) for a in B}
    idx = collections.defaultdict(list)
    for run in seqs(B):
        for i in range(len(run) - W + 1):
            idx[tuple(NB[x] for x in run[i:i + W])].append(run[i])
    votes = collections.defaultdict(collections.Counter)
    for run in seqs(A):
        for i in range(len(run) - W + 1):
            c = idx.get(tuple(NA[x] for x in run[i:i + W]))
            if c and len(c) <= 3:
                pa = run[i:i + W]
                for cb in c:
                    pb = [cb]
                    for _ in range(W - 1):
                        pb.append(pb[-1] + B[pb[-1]][0])
                    for x, y in zip(pa, pb):
                        votes[x][y] += 1
    return {x: v.most_common(1)[0][0] for x, v in votes.items()}


def name_all(A_code, A_data, B_code, B_data, symB, ids, base=0x200000):
    """Returns {addr: (name, quality)} for the target. quality: 3 blob, 2 code, 1 operand pairing."""
    real = lambda n: ids.get(n, n)
    mp = match_code(A_code, B_code)
    names = {}
    for a, b in mp.items():
        if b in symB:
            names.setdefault(a, (real(symB[b][0]), 2))
    conf = collections.defaultdict(collections.Counter)
    pat = re.compile(r'\$(2[0-3][0-9a-f]{4})')
    for a, b in mp.items():
        ta = pat.findall(A_code[a][2]); tb = pat.findall(B_code[b][2])
        if len(ta) == len(tb):
            for x, y in zip(ta, tb):
                y = int(y, 16)
                if y in symB:
                    conf[int(x, 16)][y] += 1
    for x, c in conf.items():
        y = c.most_common(1)[0][0]
        names.setdefault(x, (real(symB[y][0]), 1))
    # verbatim data blobs (>=48 bytes, unique in the target)
    blobs = []
    addrs = sorted(set(symB) | {base + len(B_data)})
    for i, a in enumerate(sorted(symB)):
        if a < base or a >= base + len(B_data):
            continue
        nxt = min([x for x in addrs if x > a] or [base + len(B_data)])
        n = symB[a][0]
        blob = B_data[a - base:nxt - base]
        if len(blob) >= 48 and not n.startswith('unk_'):
            pos = []; s = 0
            while True:
                k = A_data.find(blob, s)
                if k < 0:
                    break
                pos.append(base + k); s = k + 1
            if len(pos) == 1 and re.fullmatch(r'[A-Za-z_]\w*', n) and not n.startswith('byte_'):
                names[pos[0]] = (real(n), 3)
                blobs.append((pos[0], real(n), len(blob)))
    return names, blobs


def clean(names):
    """Drop names that are not usable labels and resolve duplicates (best quality, lowest address wins)."""
    cand = {}
    for a, (n, q) in names.items():
        if re.fullmatch(r'[A-Za-z_]\w*', n) and not n.startswith(('unk_', 'byte_', 'word_', 'loc_', 'sub_')):
            cand.setdefault(n, []).append((-q, a))
    out = {}
    for n, l in cand.items():
        l.sort(); out[l[0][1]] = n
    return out
