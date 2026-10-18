#!/usr/bin/env python3
"""
Extrae de una ronda generada por mmd2md (p.ej. R12A) SOLO lo propio de su zona/acto, listo para ensamblarse junto al
motor unico (el de PPZ Acto 1 / R11A). Uso (desde src/):  python3 ../tools/rounds/extract_round.py R12A [--dry]

- Raices: los puntos de despacho por zona (zoneVars de Level/_Definitions.inc) y LevelPaletteID. Los que la ronda no
  nombra (el decompilador solo transfiere nombres de codigo identico) se resuelven alineando las rutinas que los usan
  en el motor con sus equivalentes de la ronda.
- Clausura: se incluye lo alcanzable si es de zona (etiquetas de los archivos de zona de PPZ Acto 1) o si el motor no
  lo tiene; si el motor ya tiene una rutina con ese nombre (aunque sea otra version) se usa la del motor.
- Los punteros literales $2xxxxx pasan a etiquetas usando el mapa de direcciones de la propia ronda.
Salida: "MD Port/Zones/<R>.asm", "MD Port/Zones/<R>/_symbols.txt" y los binarios que usa (copiados a Level/.../Data/).
"""
import sys, os, re, io, shutil, hashlib, collections, bisect, contextlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rlib import *

RND = sys.argv[1]; DRY = "--dry" in sys.argv
SRC = os.environ.get("SRC", "/home/claude/scddisasm/src"); os.chdir(SRC)
PRE = RND + "_"
IDENT = re.compile(r'[A-Za-z_]\w*')
LITC = re.compile(r'\$2[0-3][0-9A-Fa-f]{4}\b')

ref = routines(round_path("R11A")); RB = {r.name: r for r in ref}; RS = collections.defaultdict(list)
for r in ref: RS[r.sig].append(r.name)
sys.argv = ["x", "Past"]
with contextlib.redirect_stdout(io.StringIO()):
    exec(open("../tools/make_zone_files.py").read().split("rename = {n for n")[0].split("# Labels that exist only")[0])
ZONE = set(P)
defs = open("Level/_Definitions.inc").read().split("zoneVars\t\trs.b\t0")[1].split("zoneVarsEnd")[0]
ROOTS = [m.group(2) for m in re.finditer(r"^(z\w+)\s+rs\.l\s+1\s*;\s*(\w+)", defs, re.M)]

cur = routines(round_path(RND)); CB = {r.name: r for r in cur}
amap = address_map(RND); AD = sorted((a, n) for n, a in amap.items()); ADK = [a for a, _ in AD]
owner = {}                                   # label (incl. loc_) -> routine that contains it
for r in cur:
    for l in r.lines:
        m = re.match(r'^([A-Za-z_]\w*):', l)
        if m: owner[m.group(1)] = r.name
def label_at(addr):
    i = bisect.bisect_right(ADK, addr) - 1
    if i < 0: return None
    a, n = AD[i]; return (n, addr - a)
RBL = [r for r in ref if r.name != "__head"]; RBI = {r.name: i for i, r in enumerate(RBL)}
alias = {}
for r in cur:
    if r.name not in RBI or r.is_auto(): continue
    i = RBI[r.name]; cum = []; bounds = []; k = 0
    while len(cum) < len(r.sig) and i + k < len(RBL):
        cum += list(RBL[i + k].sig); bounds.append(len(cum)); k += 1
    if k > 1 and tuple(cum) == r.sig:                               # the round merged consecutive engine routines
        idx = 0; at = {}
        for l in r.lines:
            m = re.match(r'^([A-Za-z_]\w*):', l)
            if m: at[idx] = m.group(1)
            if norm(l): idx += 1
        for j in range(1, k):
            lab = at.get(bounds[j - 1])
            if lab and not RBL[i + j].is_auto(): alias[lab] = RBL[i + j].name
def engine_has(r):
    if not r.is_auto() and r.name in RB: return True
    return len(r.sig) > 3 and len(RS.get(r.sig, [])) == 1 and not AUTO.fullmatch(RS[r.sig][0])
def include(n): return n in ZONE or not engine_has(CB[n])
def whole(w): return re.compile(r'(?<![\w.])' + re.escape(w) + r'(?!\w)')

# ---- raices sin nombre en la ronda: alinear rutinas equivalentes motor <-> ronda ----
pairs = {}
for r in cur:
    if not r.is_auto() and r.name in RB: pairs[r.name] = RB[r.name]
    elif len(r.sig) > 3 and len(RS.get(r.sig, [])) == 1: pairs[r.name] = RB[RS[r.sig][0]]
rootlabel = {}; unresolved = []
for R in ROOTS:
    if R in CB: rootlabel[R] = (R, 0); continue
    cand = collections.Counter(); wr = whole(R)
    for cn, rb in pairs.items():
        al = [re.sub(r'\s+', ' ', l.split(";")[0]).strip() for l in rb.lines if l.split(";")[0].strip()]
        if not any(wr.search(x) for x in al): continue
        bl = [re.sub(r'\s+', ' ', l.split(";")[0]).strip() for l in CB[cn].lines if l.split(";")[0].strip()]
        if len(al) != len(bl): continue
        for a, b in zip(al, bl):
            if not wr.search(a): continue
            m = re.match("^" + wr.sub("\0", re.escape(a)).replace("\0", r"([\w$#]+)", 1).replace(r"\ ", " ") + "$", b) if False else None
            pat = "^" + re.escape(a).replace(re.escape(R), r"([\w$#]+)", 1).replace(r"\ ", " ") + "$"
            m = re.match(pat, b)
            if m:
                t = m.group(1).lstrip("#")
                off = 0
                if LITC.fullmatch(t):
                    la = label_at(int(t[1:], 16)); t, off = (la if la else (None, 0))
                if t and t in CB: cand[(t, off)] += 1
    if cand: rootlabel[R] = cand.most_common(1)[0][0]
    else: unresolved.append(R)

# ---- clausura ----
def targets(line):
    code = line.split(";")[0]; out = set(IDENT.findall(code))
    if not re.match(r'\s*dc\.w', code):
        for m in LITC.finditer(code):
            la = label_at(int(m.group(0)[1:], 16))
            if la: out.add(la[0])
    return out
S = set(); todo = []
for R, (lab, off) in rootlabel.items():
    o = owner.get(lab, lab)
    if o not in S: S.add(o); todo.append(o)
if "LevelPaletteID" in CB and "LevelPaletteID" not in S: S.add("LevelPaletteID"); todo.append("LevelPaletteID")
while todo:
    n = todo.pop()
    for l in CB[n].lines:
        for t in targets(l):
            o = owner.get(t)
            if o and o not in S and o in CB and include(o): S.add(o); todo.append(o)
order = [r for r in cur if r.name in S]
lines = sum(len(r.sig) for r in order)

PCIDX = re.compile(r'([A-Za-z_]\w*)\(pc,')
def own_labels(rs): return {m.group(1) for r in rs for l in r.lines for m in [re.match(r'^([A-Za-z_]\w*):', l)] if m}
extras = []                                   # (routine copied from the engine, name of the routine that uses it)
while True:
    have = own_labels(order + [e for e, _ in extras]); new = []
    for r in order + [e for e, _ in extras]:
        for l in r.lines:
            for x in PCIDX.findall(l.split(";")[0]):
                if x not in have and x in RB and x not in [e.name for e, _ in new]: new.append((RB[x], r.name))
    if not new: break
    extras += new
def with_extras(r):                           # the copy goes right after its user (it is addressed with (pc,dN))
    out = [r]
    for e, host in extras:
        if host == r.name: out += with_extras(e)
    return out
order = [x for r in order for x in with_extras(r)]

# ---- renombrar / literales / saltos absolutos ----
labels = {m.group(1) for r in order for l in r.lines for m in [re.match(r'^([A-Za-z_]\w*):', l)] if m}
rx = re.compile(r'(?<![\w.$@])(' + "|".join(sorted(map(re.escape, labels), key=len, reverse=True)) + r')(?![\w])')
def ren(l):
    code, sep, cmt = l.partition(";")
    parts = re.split(r'("[^"]*")', code)
    parts = [p if p.startswith('"') else rx.sub(lambda m: PRE + m.group(1), p) for p in parts]
    return "".join(parts) + sep + cmt
warn = []; outlines = []; incbins = []; nlit = 0
for r in order:
    start = len(outlines); tramps = {}
    for l in r.lines:
        code, sep, cmt = l.partition(";")
        if not re.match(r'\s*dc\.w', code):                      # $2xxxxx pointers -> labels
            def lit(m):
                global nlit
                la = label_at(int(m.group(0)[1:], 16))
                if not la: return m.group(0)
                nlit += 1; n, off = la
                o = owner.get(n)
                if n in alias: return alias[n]
                if o and o not in S and o in CB and engine_has(CB[o]):        # points into an engine routine: use its name
                    en = o if (not CB[o].is_auto() and o in RB) else RS[CB[o].sig][0]
                    d = int(m.group(0)[1:], 16) - amap[o]
                    return en + (f"+{d}" if d else "")
                return n + (f"+{off}" if off else "")
            code2 = LITC.sub(lit, code)
            if code2 != code: l = code2 + sep + cmt
        l = ren(l)
        if alias: l = re.sub(r'(?<![\w.$@])(' + '|'.join(map(re.escape, alias)) + r')(?![\w])', lambda m: alias[m.group(1)], l)
        code, sep, cmt = l.partition(";")
        md = re.match(r'^(\s+dc\.w\s+)(.*)$', code)
        if md and "-" in md.group(2):                                  # offset table: external targets go through local trampolines
            items = []
            for it in md.group(2).split(","):
                mm = re.match(r'^\s*([A-Za-z_]\w*)\s*-\s*(\.?\w+)\s*$', it)
                if mm and not mm.group(1).startswith(PRE):
                    tl = f"{PRE}tr_{r.name}_{mm.group(1)}"; tramps.setdefault(tl, mm.group(1)); items.append(f"{tl}-{mm.group(2)}")
                else: items.append(it.strip())
            l = md.group(1) + ",".join(items) + (("\t" + sep + cmt) if sep else ""); code, sep, cmt = l.partition(";")
        code = re.sub(r'\b([A-Za-z_]\w*)\(pc\)', lambda m: m.group(0) if m.group(1).startswith(PRE) else m.group(1), code)
        l = code + sep + cmt
        m = re.match(r'^(\s+)(bsr|bra)(\.[sw])?(\s+)([A-Za-z_]\w*)\s*$', code)
        if m and not m.group(5).startswith(PRE):
            l = f"{m.group(1)}{'jsr' if m.group(2)=='bsr' else 'jmp'}{m.group(4)}{m.group(5)}" + ("\t" + sep + cmt if sep else "")
        else:
            m = re.match(r'^(\s+lea\s+)([A-Za-z_]\w*)\(pc\),(a\d)\s*$', code, re.I)
            if m and not m.group(2).startswith(PRE): l = f"{m.group(1)}{m.group(2)},{m.group(3)}" + ("\t" + sep + cmt if sep else "")
            else:
                m = re.match(r'^\s+(b(?!ra|sr)[a-z]{2}|db[a-z]+)(\.[sw])?\s+(?:d\d,)?([A-Za-z_]\w*)\s*$', code, re.I)
                if m and not m.group(3).startswith(PRE): warn.append(f"{r.name}: rama condicional externa: {code.strip()}")
        if LITC.search(l.partition(";")[0]) and not re.match(r'\s*dc\.w', l): warn.append(f"{r.name}: literal sin resolver: {l.strip()[:70]}")
        mi = re.search(r'incbin\s+"([^"]+)"', l)
        if mi: incbins.append(mi.group(1))
        outlines.append(l)
    if tramps:                                                     # jmp stubs next to the table (within 16-bit reach)
        outlines.append("\teven")
        for tl, tgt in tramps.items(): outlines.append(f"{tl}:\tjmp\t{tgt}")
    if r.name == "LevelChunks": outlines[start:start] = ["\tALIGN\t$10000\t\t\t\t; Chunk lookups replace only the low byte/word of this address", ""]

# ---- binarios ----
copied = 0; clash = []; CSRC = os.path.dirname(CCZ.rstrip("/")) + "/"
for p in sorted(set(incbins)):
    s = CSRC + p
    if not os.path.exists(s): warn.append(f"incbin no encontrado: {p}"); continue
    if os.path.exists(p):
        if hashlib.sha1(open(p, "rb").read()).digest() != hashlib.sha1(open(s, "rb").read()).digest(): clash.append(p)
        continue
    if not DRY: os.makedirs(os.path.dirname(p), exist_ok=True); shutil.copy(s, p)
    copied += 1

print(f"{RND}: rutinas propias {len(order)}/{len(cur)} | {lines} líneas | literales resueltos {nlit} | binarios {len(set(incbins))} (copiados {copied})"
      f" | alias de fusiones {len(alias)} | raíces: {len(rootlabel)}/{len(ROOTS)} sin resolver {unresolved} | choques {clash} | avisos {len(warn)}")
for w in warn[:12]: print("  AVISO", w)
if not DRY:
    os.makedirs(f"MD Port/Zones/{RND}", exist_ok=True)
    hdr = f"; Generated by tools/rounds/extract_round.py from {RND}: only what is specific to this zone/act/time zone\n; (labels prefixed with {PRE}; the engine is the one of PPZ Act 1)\n\n"
    open(f"MD Port/Zones/{RND}.asm", "w", newline="\n").write(hdr + "\n".join(outlines) + "\n")
    open(f"MD Port/Zones/{RND}/_symbols.txt", "w").write("MAP\n" + "\n".join(f"{R}={PRE}{l}" + (f"+{o}" if o else "") for R, (l, o) in rootlabel.items()) + "\n")
