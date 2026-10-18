#!/usr/bin/env python3
"""
Genera los archivos por zona de Past para ensamblarlos junto a Present en una sola ROM.

Present y Past definen las mismas etiquetas (LevelChunks, LevelScroll, ObjectIndex...), asi que no se
pueden incluir las dos tal cual. Este script toma los 9 archivos por zona de Past y:
  - renombra con el prefijo Past_ toda etiqueta que tambien existe en Present y es "por zona"
  - descarta del archivo Data los assets que son identicos a los de Present (se comparten)
  - antepone ALIGN $10000 al bloque de chunks (el motor exige esa alineacion)
"Por zona" = las etiquetas de los archivos de codigo/tablas de la zona, las que difieren de Present, y
todo lo que (transitivamente) las referencia.

Uso (desde src/):  python3 ../tools/make_zone_files.py [Past]
Salida: "MD Port/Zones/<Zona>/<archivo>.asm" y "MD Port/Zones/<Zona>/_symbols.txt"
"""
import re, os, sys, hashlib, collections

ZONE = sys.argv[1] if len(sys.argv) > 1 else "Past"
PREFIX = ZONE.replace(" ", "") + "_"
ZDIR = ZONE.replace(" ", "")
BASE = "Level/Palmtree Panic/"
SRC_FILES = [  # nombre en Present -> Data es el unico archivo de assets
    BASE + "Palette Cycle (Present).asm", BASE + "Palette Data (Act 1 Present).asm",
    BASE + "Scroll (Act 1 Present).asm", BASE + "Object Index (Act 1 Present).asm",
    BASE + "Debug Objects (Act 1 Present).asm", BASE + "Objects/Collapsing Platform/Data (Present).asm",
    BASE + "Section Data (Act 1 Present).asm", BASE + "Object Tile IDs (Act 1 Present).asm",
    BASE + "Data (Act 1 Present).asm"]
def zfile(f):
    if "Future" in ZONE and f.endswith("Collapsing Platform/Data (Present).asm"):
        return f.replace("Data (Present).asm", "Data (Future).asm")          # both futures share this file
    return f.replace("Present", ZONE)
DATA = BASE + "Data (Act 1 Present).asm"
LAB = re.compile(r'^([A-Za-z_]\w*):?(?=\s|$)')
IDENT = re.compile(r'[A-Za-z_]\w*')

def read(p): return open(p, errors="replace").read().replace("\r", "").split("\n")

ENGINE = {"Level/Palette Cycle Script.asm", "Level/Scroll Flag Set.asm", "Level/Block Draw.asm"}   # shared engine code, assembled once by Present
def read_expanded(path):
    """read() but with nested .asm includes expanded inline (so their labels get renamed/compared like the rest)."""
    out = []
    for l in read(path):
        m = re.match(r'\s*include\s+"([^"]+\.asm)"', l)
        if m and m.group(1) in ENGINE:
            # the original falls through into the included code: jump to its first label instead of repeating it
            first = next(mm.group(1) for x in read(m.group(1)) if x and x[0] not in "\t ;." for mm in [LAB.match(x)] if mm)
            out.append("\t; (shared engine code, assembled once by the Present zone) " + l.strip())
            out.append(f"\tjmp\t{first}\t\t\t\t; (the original falls through into that code)"); continue
        if m and os.path.exists(m.group(1)):
            out.append("\t; ---- begin " + m.group(1))
            for x in read_expanded(m.group(1)):
                if x.strip() == "" or x.lstrip().startswith(";") and x[:1] not in "\t ": continue   # keep blocks contiguous
                out.append(x)
            out.append("\t; ---- end " + m.group(1)); continue
        out.append(l)
    return out

def bodies(path):
    out = collections.OrderedDict(); cur = None
    for l in read_expanded(path):
        if l and l[0] not in "\t ;.":
            m = LAB.match(l)
            if m: cur = m.group(1); out[cur] = []
        if cur is None: continue
        t = l.split(";")[0].strip()
        if not t: continue
        m2 = re.match(r'incbin\s+"([^"]+)"', t)
        if m2:
            p = m2.group(1)
            t = "incbin " + (hashlib.sha1(open(p, "rb").read()).hexdigest()[:10] if os.path.exists(p) else p)
        out[cur].append(re.sub(r'\s+', ' ', t))
    return out

def refs_in(body):
    s = set()
    for ln in body:
        if ln.startswith("incbin") or ln.startswith("include"): continue
        s |= set(IDENT.findall(ln.split(" ", 1)[1] if " " in ln else ""))
    return s

P, Q, code_labels = {}, {}, set()
for f in SRC_FILES:
    b = bodies(f); P.update(b)
    if f != DATA: code_labels |= set(b)
    Q.update(bodies(zfile(f)))

bad = {n for n in P if n in Q and P[n] != Q[n]} | {n for n in P if n not in Q} | code_labels
DIFF = re.compile(r'[\w.]\s*-\s*[.\w]')
def diff_labels(n):
    """labels used in label-difference expressions (dc.w A-B offset tables) inside the body of n"""
    s = set()
    for ln in P.get(n, []) + Q.get(n, []):
        if ln.startswith(("incbin", "include")) or not DIFF.search(ln): continue
        s |= {t for t in IDENT.findall(ln.split(" ", 1)[1] if " " in ln else "") if t in P}
    return s
changed = True
while changed:
    changed = False
    for n in P:
        if n not in bad and any(t in bad for t in refs_in(P[n])): bad.add(n); changed = True
    for n in list(bad):                      # offset tables need their targets next to them
        for t in diff_labels(n):
            if t not in bad: bad.add(t); changed = True

FORCE = {"LevelPaletteID"}     # read right after LevelDataIndex by LoadLevelData
bad |= FORCE
# Labels that exist only in this zone are renamed too: shared code can never reference them (Present would not
# assemble), and several zones may generate the same auto-names (byte_20c446...).
rename = {n for n in Q if n in P and n in bad} | {n for n in Q if n not in P}
drop = {n for n in Q if n in P and n not in bad}            # shared assets (only exist in Data)
assert not (drop & code_labels)

rx = re.compile(r'(?<![\w.$@])(' + "|".join(sorted(map(re.escape, rename), key=len, reverse=True)) + r')(?!\w)')
def rename_line(l):
    code, sep, cmt = l.partition(";")
    parts = re.split(r'("[^"]*")', code)           # keep quoted strings untouched
    parts = [p if p.startswith('"') else rx.sub(lambda m: PREFIX + m.group(1), p) for p in parts]
    return "".join(parts) + sep + cmt

def drop_blocks(lines):
    out, i = [], 0
    while i < len(lines):
        l = lines[i]
        m = LAB.match(l) if l and l[0] not in "\t ;." else None
        if m and m.group(1) in drop:
            i += 1
            while i < len(lines) and (lines[i][:1] in ("\t", " ") or lines[i].startswith(".")): i += 1   # indented lines and local labels belong to the block
            continue
        out.append(l); i += 1
    return out

# nested includes that Present already assembles (shared engine code): do not repeat them
present_includes = set()
for f in SRC_FILES:
    for l in read(f):
        m = re.match(r'\s+include\s+"([^"]+)"', l)
        if m: present_includes.add(m.group(1))

def defined_in(lines):
    return {m.group(1) for l in lines if l and l[0] not in "\t ;." for m in [LAB.match(l)] if m}

warnings = []
def absolutize(lines, fname):
    """The zone code lives far from the shared engine: bsr/bra/lea(pc) to labels outside this file become absolute."""
    here = defined_in(lines)
    ext = lambda t: not t.startswith(".") and t not in here
    out = []
    for n, l in enumerate(lines, 1):
        code, sep, cmt = l.partition(";")
        m = re.match(r'^(\s+)(bsr|bra)(\.[sw])?(\s+)([A-Za-z_]\w*)\s*$', code)
        if m and ext(m.group(5)):
            op = "jsr" if m.group(2) == "bsr" else "jmp"
            l = f"{m.group(1)}{op}{m.group(4)}{m.group(5)}" + ("\t" + sep + cmt if sep else "")
        else:
            m = re.match(r'^(\s+lea\s+)([A-Za-z_]\w*)\(pc\),(a\d)\s*$', code, re.I)
            if m and ext(m.group(2)):
                l = f"{m.group(1)}{m.group(2)},{m.group(3)}" + ("\t" + sep + cmt if sep else "")
            else:
                m = re.match(r'^\s+(b(?!ra|sr)[a-z]{2}|dbf|dbra|db[a-z]{2})(\.[sw])?\s+(?:d\d,)?([A-Za-z_]\w*)\s*$', code, re.I)
                if m and ext(m.group(3)): warnings.append(f"{fname}:{n}: rama condicional a etiqueta externa: {code.strip()}")
                m = re.search(r'([A-Za-z_]\w*)\(pc,\s*[ad]\d', code)
                if m and ext(m.group(1)): warnings.append(f"{fname}:{n}: pc indexado a etiqueta externa: {code.strip()}")
        out.append(l)
    return out

order = list(Q.keys())
for a_, b_ in zip(order, order[1:]):
    if a_ in rename and b_ in drop:
        print(f"REVISAR: {b_} (compartido) sigue a {a_} (por zona): si el codigo lee de corrido, forzarlo en FORCE")

outdir = f"MD Port/Zones/{ZDIR}"; os.makedirs(outdir, exist_ok=True)
produced = []
for f in SRC_FILES:
    zf = zfile(f); lines = read_expanded(zf)
    if f == DATA: lines = drop_blocks(lines)
    lines = [rename_line(l) for l in lines]
    lines = absolutize(lines, os.path.basename(zf))
    if f == DATA:
        i = next(k for k, l in enumerate(lines) if l.startswith(PREFIX + "LevelChunks:"))
        lines[i:i] = ["\tALIGN\t$10000\t\t\t\t; Chunk lookups replace only the low byte/word of this address", ""]
    hdr = [f"; Generated by tools/make_zone_files.py from \"{zf}\"",
           f"; (labels shared with the Present zone are prefixed with {PREFIX}; identical assets are not repeated)", ""]
    name = os.path.basename(zf)
    open(f"{outdir}/{name}", "w", newline="\n").write("\n".join(hdr + lines)); produced.append(name)
open(f"MD Port/Zones/{ZDIR}.asm", "w", newline="\n").write(
    "; -------------------------------------------------------------------------\n; Sonic CD Disassembly - Mega Drive port\n; -------------------------------------------------------------------------\n"
    f"; Palmtree Panic Act 1 {ZONE}: zone files (generated by tools/make_zone_files.py)\n; -------------------------------------------------------------------------\n\n"
    + "".join(f'\tinclude\t"MD Port/Zones/{ZDIR}/{n}"\n' for n in produced))
# symbols of the shared engine that reference zone labels (candidates for runtime dispatch)
_inc = re.findall(r'include\s+"([^"]+)"', "\n".join(read(BASE + "Act 1 Present.asm")))
_shared = [f for f in _inc if f not in SRC_FILES and os.path.exists(f) and not f.endswith(".inc")]
_tok = set()
for f in _shared:
    for l in read(f): _tok |= set(IDENT.findall(l.split(";")[0]))
dispatch = sorted(rename & _tok)
open(f"{outdir}/_symbols.txt", "w").write("DISPATCH (renamed here and referenced from shared engine code)\n" + "\n".join(dispatch) + "\n\n" +
    "RENAMED\n" + "\n".join(sorted(rename)) + "\n\nDROPPED (shared with Present)\n" + "\n".join(sorted(drop)) + "\n")
for w in warnings: print("AVISO", w)
print(f"{ZONE}: {len(rename)} etiquetas renombradas, {len(drop)} assets compartidos descartados, "
      f"{len(Q.keys() - set(P))} etiquetas solo de {ZONE} (sin cambios)")
