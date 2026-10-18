"""Emits a split, re-assemblable source (asm68k syntax) for one round MMD.

emit(d, ana, names, blobs, S, defs, opts, raw) -> (asm_text, files, info)
  files: {path relative to the repo's src folder: bytes}
"""
import hashlib, os, re, struct
from . import nem as nemmod
from .levelstruct import PLC_NAMES


def levelstruct_names():
    return PLC_NAMES

BASE = 0x200000
BR = r'(b(ra|sr|hi|ls|cc|cs|ne|eq|vc|vs|pl|mi|ge|lt|gt|le|hs|lo))\.b$'


class Opts:
    zone_dir = 'Level/Collision Chaos'        # relative to src
    act = 'Act 1 Present'                      # e.g. "Act 1 Present"
    act_short = 'Act 1'                        # objects file suffix
    title = 'R31A'
    shared = {}                                # sha1 -> path (relative to src) of identical common data files
    tail = None                                # data after this address is split into files more eagerly
    segmin = 0x100
    romvars = {}                               # addr -> (name, size) data moved to RAM in the MD build
    hooks = True


def _clean(n):
    return re.sub(r'[^A-Za-z0-9_ ()\-]', '_', n)


def emit(d, ana, names, blobs, S, defs, opts, raw=frozenset()):
    sym, obj = defs
    END = BASE + len(d)
    code = ana.code; tabs = ana.tabs
    ldi = S['ldi']
    TAIL = opts.tail if opts.tail is not None else ldi - 0x1000
    files = {}
    info = {'segments': [], 'warnings': []}
    DD = opts.zone_dir + '/Data'
    act = opts.act

    # ---------------------------------------------------------------- items
    items = {}
    for a, (sz, m, o) in code.items():
        items[a] = (sz, 'code', (m, o))
    for T, (kind, n, ent, end) in tabs.items():
        if kind == 'word':
            for j, t in enumerate(ent):
                items[T + 2 * j] = (2, 'wordoff', (T, t))
    cov = set()
    for a, (sz, m, o) in code.items():
        cov.update(range(a, a + sz))
    for T, (kind, n, ent, end) in tabs.items():
        cov.update(range(T, end))
    PT = {}
    o = 0
    while o < len(d) - 4:
        k = o; n = 0
        while k + 4 <= len(d) and (BASE + k) not in cov and (BASE + k + 3) not in cov:
            v = struct.unpack('>I', d[k:k + 4])[0]
            if BASE + 0x100 <= v < END and v & 1 == 0:
                n += 1; k += 4
            else:
                break
        if n >= 6:
            for j in range(n):
                items[BASE + o + 4 * j] = (4, 'ptr', struct.unpack('>I', d[o + 4 * j:o + 4 * j + 4])[0])
            PT[BASE + o] = n; o = k
        else:
            o += 2

    # ---------------------------------------------------------------- names
    NM = dict(names)
    SPECIAL = {0x200100: 'JmpTo_Start', 0x200106: 'JmpTo_Error', 0x20010c: 'JmpTo_HInt', 0x200112: 'JmpTo_VInt',
               S['ldi']: 'LevelDataIndex', S['chunks']: 'LevelChunks', S['blocks']: 'LevelBlocks',
               S['art']: 'Art_LevelTiles'}
    if S.get('demo'): SPECIAL[S['demo']] = 'LevelDemo'
    if S.get('collision'): SPECIAL[S['collision']] = 'LevelCollision'
    if S.get('layouts'): SPECIAL[S['layouts']] = 'LevelLayouts'
    if S.get('objlayouts'): SPECIAL[S['objlayouts']] = 'ObjectLayouts'
    if S.get('paltable'): SPECIAL[S['paltable']] = 'PaletteTable'
    used = {v: k for k, v in SPECIAL.items()}
    for a in [a for a, n in NM.items() if n in used and used[n] != a]:
        del NM[a]
    for a, n in SPECIAL.items():
        NM[a] = n
    # unique names
    seen = {}
    for a in sorted(NM):
        n = NM[a]
        if n in seen:
            NM[a] = '%s_%06X' % (n, a)
        seen[NM[a]] = a
    OBJT = next((a for a in PT if NM.get(a) == 'ObjectIndex'), None)

    # ---------------------------------------------------------------- refs (labels)
    refs = {}

    def ref(a, k):
        if BASE <= a < END:
            refs.setdefault(a, k)
    for x in (0x200100, 0x200106, 0x20010c, 0x200112):
        ref(x, 'sub')
    for a, (sz, m, o) in code.items():
        if m in ('bsr', 'jsr') or m.startswith('bsr'):
            mo = re.match(r'\$([0-9a-f]+)(\.[lw])?$', o.split(',')[-1].strip())
            if mo:
                ref(int(mo.group(1), 16), 'sub')
        for mo in re.finditer(r'\$(2[0-3][0-9a-f]{4})(?:\.l)?(?![0-9a-f(])', o):
            ref(int(mo.group(1), 16), 'loc')
        for mo in re.finditer(r'\$([0-9a-f]+)\(pc', o):
            ref(int(mo.group(1), 16), 'dat')
    for T, n in PT.items():
        refs[T] = 'ptrtbl'
        for j in range(n):
            v = items[T + 4 * j][2]
            if T == OBJT:
                refs[v] = 'obj'
            else:
                ref(v, 'dat')
    for T, (kind, n, ent, end) in tabs.items():
        ref(T, 'tbl')
        for t in ent:
            ref(t, 'loc')
    OBJIDX = {}
    if OBJT:
        for j in range(PT[OBJT]):
            OBJIDX.setdefault(items[OBJT + 4 * j][2], j + 1)

    # ---------------------------------------------------------------- anchors
    ANC = {}

    def anc(a, why):
        if BASE <= a < END:
            ANC.setdefault(a, set()).add(why)
    for a, (sz, m, o) in code.items():
        if m in ('bsr', 'jsr') or (re.match(r'(b|db)[a-z]+', m) and m not in ('btst', 'bset', 'bclr', 'bchg')):
            continue
        for mo in re.finditer(r'\$(2[0-3][0-9a-f]{4})\.l|#\$(2[0-3][0-9a-f]{4})\b', o):
            anc(int(mo.group(1) or mo.group(2), 16), 'code')
        for mo in re.finditer(r'\$([0-9a-f]+)\(pc', o):
            anc(int(mo.group(1), 16), 'pc')
    for v in (S['art'], S['blocks'], S['chunks']):
        anc(v, 'ldi')
    # PLC pointers
    PLCL = {}
    if S.get('plc'):
        pl = S['plc'] - BASE
        for off in sorted(set(S['plc_offs'])):
            p = pl + off; cnt = struct.unpack('>H', d[p:p + 2])[0]
            if off in (S['plc_offs'][0], S['plc_offs'][1]):
                for i in range(cnt + 1):
                    ptr = struct.unpack('>I', d[p + 2 + 6 * i:p + 6 + 6 * i])[0]
                    anc(ptr, 'plc'); ref(ptr, 'dat')
    for a, nm, sz in blobs:
        anc(a, 'blob'); anc(a + sz, 'blobend')
    for k in ('demo', 'collision', 'layouts', 'objlayouts', 'paltable'):
        if S.get(k):
            anc(S[k], k)

    # ------------------------------------------------ special blocks (start -> end)
    SPEC = {}                                  # start -> (end, kind)
    nextanc = lambda a: min([x for x in list(ANC) + list(refs) if x > a] + [END])
    SPEC[ldi] = (S['chunks'], 'ldi')
    # palette table
    PAL = {}
    if S.get('paltable'):
        pt = S['paltable']; ents = []
        pv = (sym.get('palette', 0xFB00)) & 0xFFFF
        k = pt - BASE
        while k + 8 <= len(d):
            ptr, dest, cnt = struct.unpack('>IHH', d[k:k + 8])
            if not (BASE + 0x100 <= ptr < END) or not (pv <= dest < pv + 0x80) or cnt > 0x3F:
                break
            ents.append((ptr, dest, cnt)); k += 8
        if ents:
            SPEC[pt] = (pt + 8 * len(ents), 'paltable')
            PAL = {'ents': ents}
            for ptr, dest, cnt in ents:
                anc(ptr, 'pal'); ref(ptr, 'dat')
    if S.get('layouts'):
        lo = S['layouts']
        # block ends at the next anchor that is not inside it (header offsets are not anchors yet)
        SPEC[lo] = (nextanc(lo), 'layouts')
    if S.get('objlayouts'):
        r = S['objlayouts']
        nul = struct.unpack('>H', d[r - BASE + 2:r - BASE + 4])[0]
        if d[r - BASE + 4:r - BASE + 12] == bytes.fromhex('ffff000000000000') and \
                d[r - BASE + nul:r - BASE + nul + 6] == bytes.fromhex('ffff00000000'):
            SPEC[r] = (r + nul + 6, 'objlayouts')
    for a, (e, k) in SPEC.items():
        refs[a] = 'seg'
    SPECEND = {e for a, (e, k) in SPEC.items()}

    # ---------------------------------------------------------------- walk memory
    order = []

    def nameof(a):
        return NM.get(a)

    def dataitems(s, e):
        o = s
        cuts = sorted(set(a for a in list(refs) + list(ANC) + list(SPEC) + list(SPECEND) if s < a < e))
        while o < e:
            if o in SPEC and SPEC[o][0] <= e:
                order.append((o, SPEC[o][0] - o, 'special', SPEC[o][1]))
                o = SPEC[o][0]
                continue
            nxt = min([c for c in cuts if c > o] + [e])
            n = nxt - o
            nm_ = nameof(o)
            if o % 2 == 0 and ((n >= opts.segmin and o >= TAIL) or n >= 0x400 or (nm_ and n >= 0x40 and o >= TAIL)):
                order.append((o, n, 'seg', None)); refs[o] = 'seg'; o += n; continue
            if o % 2 or n == 1:
                order.append((o, 1, 'byte', None)); o += 1
            else:
                n = min(n, 16) & ~1 or 1
                if n == 1:
                    order.append((o, 1, 'byte', None)); o += 1
                else:
                    order.append((o, n, 'words', None)); o += n
    a = BASE
    while a < END:
        if a in items:
            sz, k, pl = items[a]; order.append((a, sz, k, pl)); a += sz
        else:
            e = a + 1
            while e < END and e not in items:
                e += 1
            dataitems(a, e); a = e
    starts = {o[0] for o in order}
    for x in [x for x in refs if x not in starts]:
        refs.pop(x)

    def kindname(a, k):
        if a in NM:
            return NM[a]
        if k == 'seg':
            return 'Data_%06X' % a
        if k == 'ptrtbl':
            return 'ptrtbl_%06X' % a
        if k == 'obj':
            return 'Obj%02X_%06X' % (OBJIDX.get(a, 0), a)
        return {'sub': 'sub', 'loc': 'loc', 'dat': 'dat', 'tbl': 'tbl'}[k] + '_%06X' % a

    def lab(a):
        return kindname(a, refs[a]) if a in refs else '$%X' % a

    # --------------------------------------------------------- operand conversion
    REV = {}
    for k_, v in sym.items():
        if isinstance(v, int):
            vv = v & 0xFFFFFFFF
            if vv >= 0xA00000 and vv not in REV:
                REV[vv] = k_
    OREV = {}
    for k_, v in obj.items():
        OREV.setdefault(v, k_)

    def nm(o):
        def a_abs(mo):
            v = int(mo.group(1), 16); suf = mo.group(2)
            if suf == '.w' and v >= 0x8000:
                v |= 0xFFFF0000
            if suf == '.w' and v < 0x8000:
                return mo.group(0)
            n = REV.get(v)
            return (n + suf) if n else ('$%08X.w' % v if suf == '.w' else mo.group(0))
        o = re.sub(r'(?<![#\w$(])\$([0-9a-f]+)(\.[wl])(?![\w(])', a_abs, o)
        o = re.sub(r'(?<![\w$])-?\$([0-9a-f]+)\(a0\)',
                   lambda mo: (OREV.get(int(mo.group(1), 16), None) or '$' + mo.group(1)) + '(a0)'
                   if not mo.group(0).startswith('-') else mo.group(0), o)
        return o

    def conv(m, o):
        mm = m
        if re.match(BR, mm):
            mm = mm[:-2] + '.s'
        if mm in ('lea.l', 'pea.l', 'jmp.l', 'jsr.l'):
            mm = mm[:-2]

        def sub_abs(mo):
            v = int(mo.group(1), 16); suf = mo.group(2) or ''
            return lab(v) + suf if v in refs and suf != '.w' else mo.group(0)
        o2 = re.sub(r'\$([0-9a-f]+)\(pc', lambda mo: (lab(int(mo.group(1), 16)) + '(pc'), o)
        o2 = re.sub(r'(?<![#\w(])\$(2[0-3][0-9a-f]{4})(\.l)?(?![0-9a-f])', sub_abs, o2)
        if re.match(r'(btst|bset|bclr|bchg)\.b$', mm) and re.search(r',\s*d[0-7]$', o2):
            mm = mm[:-2] + '.l'
        if re.match(r'(btst|bset|bclr|bchg)\.l$', mm) and not re.search(r',\s*d[0-7]$', o2):
            mm = mm[:-2] + '.b'
        return mm, nm(o2)

    # ------------------------------------------------------------ file helpers
    def put(path, data):
        files[path] = data
        return path

    def share(data):
        return opts.shared.get(hashlib.sha1(data).hexdigest())

    def datafile(sub, fname, data):
        """Returns the path (relative to src) to incbin; reuses identical common files."""
        sh = share(data)
        if sh:
            return sh
        return put('%s/%s/%s' % (DD, sub, fname) if sub else '%s/%s' % (DD, fname), data)

    def ext_of(n, nem_flag):
        return '.nem' if nem_flag else '.bin'

    SEGLOG = info['segments']

    def segment(a, sz):
        """Splits one big data region into files; returns asm lines."""
        blob = d[a - BASE:a - BASE + sz]
        n = NM.get(a)
        why = ANC.get(a, set())
        nemr = nem_size_exact(blob)
        lines = []
        if n is None:
            n = ('Art_%06X' % a) if nemr else ('Data_%06X' % a)
        if a == S['chunks']:
            fn = 'Chunks (%s)' % act; sub = 'Level'
        elif a == S['blocks']:
            fn = 'Blocks (%s)' % act; sub = 'Level'
        elif a == S['art']:
            fn = 'Tiles (%s)' % act; sub = 'Level'
        elif a == S.get('demo'):
            fn = 'Demo (%s)' % act; sub = 'Level'
        elif a == S.get('collision'):
            fn = 'Collision (%s)' % act; sub = 'Collision'
        elif n == 'Art_Sonic':
            fn = 'Art (Sonic)'; sub = 'Art'
        elif n == 'DPLC_Sonic':
            fn = 'DPLC (Sonic)'; sub = 'Mappings'
        elif n.startswith('Art_') or (nemr and why & {'plc', 'ldi'}):
            fn = n; sub = 'Art'
        elif n.startswith(('MapSpr_', 'DPLC_')):
            fn = n; sub = 'Mappings'
        elif n.startswith('Ani_'):
            fn = n; sub = 'Animations'
        elif n.startswith('Pal_'):
            fn = n; sub = 'Palette'
        elif n in ('ColAngleMap', 'ColHeightMap', 'ColWidthMap'):
            fn = n; sub = 'Collision'
        else:
            fn = n; sub = 'Misc'
        isnem = bool(nemr) and (n.startswith('Art_') or a in (S['blocks'], S['art']) or nemr and 'plc' in why)
        if a == S['chunks'] or a == S.get('demo') or a == S.get('collision'):
            isnem = False
        path = datafile(sub, fn + ext_of(n, isnem), blob)
        SEGLOG.append((a, sz, n, path))
        lines.append('\tincbin\t"%s"' % path)
        return lines

    def nem_size_exact(blob):
        r = nemmod.nem_size(blob, 0)
        if r and 0 <= len(blob) - r[0] <= 3:
            return r
        return None

    # --------------------------------------------------------------- specials
    def special(a, sz, kind):
        L = []
        o = a - BASE
        if kind == 'ldi':
            L += ['LevelDataIndex:', '\tdc.l\t$3000000|Art_LevelTiles', '\tdc.l\t$2000000|LevelBlocks',
                  '\tdc.l\tLevelChunks', '\tdc.b\t%d' % d[o + 12], '\tdc.b\t$%02X' % d[o + 13], '',
                  'LevelPaletteID:', '\tdc.b\t%d' % d[o + 14], '\tdc.b\t%d' % d[o + 15], '']
            if S.get('plc'):
                pl = S['plc'] - BASE
                offs = S['plc_offs']
                pn = (list(levelstruct_names()) + ['PLC_List%d' % i for i in range(19, 64)])[:len(offs)]
                first = {}
                usedn = {}
                for o2, n_ in zip(offs, pn):
                    if o2 in first:
                        continue
                    usedn[n_] = usedn.get(n_, 0) + 1
                    first[o2] = n_ if usedn[n_] == 1 else '%s_%d' % (n_, usedn[n_])
                L.append('PLCLists:')
                for o2 in offs:
                    L.append('\tdc.w\t%s-PLCLists' % first[o2])
                L.append('')
                end = pl + 2 * len(offs); cur = end
                for o2 in sorted(first):
                    n_ = first[o2]; p = pl + o2
                    if p > cur:
                        L.append('\tdc.b\t' + ','.join('$%02X' % b for b in d[cur:p]))
                    cnt = struct.unpack('>H', d[p:p + 2])[0]
                    L.append('%s:' % n_); L.append('\tdc.w\t$%X' % cnt)
                    if o2 in (offs[0], offs[1]):
                        for i in range(cnt + 1):
                            ptr, v = struct.unpack('>IH', d[p + 2 + 6 * i:p + 8 + 6 * i])
                            L.append('\tdc.l\t%s' % (lab(ptr) if ptr in refs else '$%X' % ptr)); L.append('\tdc.w\t$%X' % v)
                        end = max(end, p + 2 + 6 * (cnt + 1)); cur = end
                    else:
                        for i in range(cnt + 1):
                            L.append('\tdc.w\t$%X' % struct.unpack('>H', d[p + 2 + 2 * i:p + 4 + 2 * i])[0])
                        end = max(end, p + 2 + 2 * (cnt + 1)); cur = end
                    L.append('')
                pad = d[end:(a - BASE + sz)]
            else:
                pad = d[o + 16:o + sz]
            if pad:
                path = datafile('Level', 'Padding (%s).bin' % act, pad)
                L.append('\tincbin\t"%s"' % path)
        elif kind == 'layouts':
            hdr = struct.unpack('>36H', d[o:o + 72])
            offs = sorted(set(hdr))
            pts = offs + [sz]
            size = {x: y - x for x, y in zip(pts, pts[1:])}
            labels = {}; fnames = {}
            cnt = {'Foreground': 0, 'Background': 0, 'Layout': 0, 'Null': 0}
            for row in range(4):
                for slot in range(3):
                    off = hdr[row * 3 + slot]
                    if off in labels:
                        continue
                    if size[off] < 8:
                        cnt['Null'] += 1
                        labels[off] = 'Null' if cnt['Null'] == 1 else 'Null%d' % cnt['Null']
                    else:
                        kind_ = ('Foreground', 'Background', 'Layout')[slot]
                        cnt[kind_] += 1
                        c = cnt[kind_]
                        short = {'Foreground': 'FG', 'Background': 'BG', 'Layout': 'LY'}[kind_]
                        labels[off] = short if c == 1 else '%s%d' % (short, c)
                        fnames[off] = '%s%s (%s)' % (kind_, '' if c == 1 else ' %d' % c, act)
            for off in offs:
                if off not in labels:
                    labels[off] = 'L%04X' % off
            L.append('LevelLayouts:')
            for r in range(0, 36, 3):
                L.append('\tdc.w\t' + ', '.join('.%s-LevelLayouts' % labels[h] for h in hdr[r:r + 3]))
            for x in offs:
                L.append('.%s:' % labels[x])
                y = x + size[x]
                if size[x] >= 8:
                    fn = fnames.get(x, 'Layout %04X (%s)' % (x, act))
                    path = datafile('Level', fn + '.bin', d[o + x:o + y])
                    L.append('\tincbin\t"%s"' % path)
                elif y > x:
                    L.append('\tdc.b\t' + ','.join('$%02X' % b for b in d[o + x:o + y]))
        elif kind == 'objlayouts':
            nul = struct.unpack('>H', d[o + 2:o + 4])[0]
            L += ['ObjectLayouts:', '\tdc.w\t.Layout-ObjectLayouts', '\tdc.w\t.Null-ObjectLayouts',
                  '\tdc.w\t$FFFF,0,0,0', '.Layout:']
            path = datafile('Objects', 'Objects (%s).bin' % opts.act_short, d[o + 12:o + nul])
            L += ['\tincbin\t"%s"' % path, '.Null:', '\tdc.w\t$FFFF,0,0']
        elif kind == 'paltable':
            L.append('PaletteTable:')
            pv = (sym.get('palette', 0xFB00)) & 0xFFFF
            pname = 'palette' if 'palette' in sym else None
            for ptr, dest, cnt in PAL['ents']:
                L.append('\tdc.l\t%s' % lab(ptr))
                if pname:
                    dd = dest - pv
                    L.append('\tdc.w\t%s' % (pname if dd == 0 else '%s+$%X' % (pname, dd)))
                else:
                    L.append('\tdc.w\t$%04X' % dest)
                L.append('\tdc.w\t$%X' % cnt)
        return L

    # ------------------------------------------------------------------- output
    out = []
    CODELINE = {}
    out.append('; %s (%s) - generated by tools/mmd2md from %s\n; Load address $200000. MDPORT=1 builds the Mega Drive version (see MD Port/).\n'
               '\tif def(MDPORT)=0\n\tinclude\t"Level/_Definitions.inc"\n\tendif\n\n\tif def(MDPORT)\n'
               '\tdcb.b\t$200000-*,$FF\t\t; the level lives at its original Word RAM address, now in cartridge ROM\n'
               '\telse\n\torg\t$200000\n\tendif\n' % (opts.title, opts.zone_dir.split('/')[-1] + ' ' + act, opts.title))
    sc0, sc1 = S.get('sub_cmd'), S.get('sub_cmd_end')
    ga = set(S.get('ga_writes', []))
    for a, sz, k, pl in order:
        if opts.hooks and sc0 and a == sc0:
            out.append('\tif def(MDPORT)\n\tinclude\t"MD Port/Sound Stub.asm"\n\tif *>$%X\n'
                       '\tfail "Sound stub is bigger than the original code (the level needs every address kept)"\n'
                       '\tendif\n\tdcb.w\t($%X-*)/2,$4E71\n\telse' % (sc1, sc1))
        if opts.hooks and sc1 and a == sc1:
            out.append('\tendif')
        if a in refs and k != 'special':
            out.append('%s:' % lab(a))
        if opts.hooks and k == 'code' and a in ga:
            out.append('\tif def(MDPORT)\n\tdcb.w\t%d,$4E71\t\t; same size as the removed GATEARRAY access (keeps every address)\n\telse' % (sz // 2))
        if k == 'code':
            m, o = pl; mm, oo = conv(m, o)
            if a in raw or re.search(r'\$0\(a[0-7]\)', oo):
                rawb = ','.join('$%02X' % b for b in d[a - BASE:a - BASE + sz])
                out.append('\tdc.b\t%s\t\t; %s %s (raw: not reproducible by assembler)' % (rawb, mm, oo))
            else:
                out.append('\t%-8s%s' % (mm, oo)); CODELINE[len(out) - 1] = a
            if opts.hooks and a in ga:
                out.append('\tendif')
        elif k == 'wordoff':
            T, t = pl
            if t in refs and T in refs:
                out.append('\tdc.w\t%s-%s' % (lab(t), lab(T)))
            else:
                out.append('\tdc.w\t$%04X' % struct.unpack('>H', d[a - BASE:a - BASE + 2])[0])
        elif k == 'special':
            out += special(a, sz, pl)
        elif k == 'seg':
            out += segment(a, sz)
        elif k == 'ptr':
            out.append('\tdc.l\t%s' % (lab(pl) if pl in refs else '$%X' % pl))
        elif k == 'words':
            ws = [struct.unpack('>H', d[a - BASE + j:a - BASE + j + 2])[0] for j in range(0, sz, 2)]
            out.append('\tdc.w\t' + ','.join('$%04X' % w for w in ws))
        else:
            out.append('\tdc.b\t$%02X' % d[a - BASE])
    info['order'] = order
    # assembler line number (1-based) -> instruction address
    lm = {}; ln = 0
    for idx, s in enumerate(out):
        ln += 1 + s.count('\n') if False else 0
    ln = 0
    for idx, s in enumerate(out):
        first = ln + 1
        ln += s.count('\n') + 1
        if idx in CODELINE:
            lm[first] = CODELINE[idx]
    info['linemap'] = lm
    info['refs'] = len(refs)
    return '\n'.join(out) + '\n', files, info
