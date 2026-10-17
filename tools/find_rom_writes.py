#!/usr/bin/env python3
"""
Busca datos guardados DENTRO del codigo que el programa luego escribe.

En Sega CD los MMD corrian desde RAM, asi que podian hacer
    Counter:  dc.w 0            ...   addq.w #1,Counter
En un cartucho de Mega Drive la ROM no es escribible: esas escrituras se pierden
en silencio (contadores que no avanzan, ciclos de paleta congelados, scroll quieto).

Uso:  tools/find_rom_writes.py <carpeta-o-archivo.asm> [...]   (desde la carpeta src/)

Detecta:
  1) instruccion que escribe directamente a un label definido con dc.*/ds.*
  2) 'lea label(pc),aN' (o #label) seguido de una escritura por (aN)/d(aN)
No detecta escrituras con direcciones calculadas a mano: para eso usar el log de
escrituras a ROM de un emulador (ver README).
"""
import re, sys, glob, os

def collect(paths):
    out = []
    for p in paths:
        if os.path.isdir(p):
            out += glob.glob(os.path.join(p, "**", "*.asm"), recursive=True)
        else:
            out.append(p)
    return sorted(set(out))

LAB = re.compile(r'^(\.?[A-Za-z_]\w*):?(\s|$)')
DC  = re.compile(r'^(dc|dcb|ds)\.[bwl]\b')
WR  = {"move","moveq","clr","add","addi","addq","sub","subi","subq","bset","bclr","bchg","neg",
       "not","eor","eori","or","ori","and","andi","asl","asr","lsl","lsr","rol","ror","st","sf","tas"}
SINGLE = {"clr","st","sf","tas","neg","not"}
IDENT = re.compile(r'\.?[A-Za-z_]\w*')
LEA = re.compile(r'^(?:lea|move\.l)\s+#?(\.?\w+)(?:\(pc\))?,\s*(a[0-6])\s*$', re.I)

def code(line):
    return line.split(";")[0].rstrip()

def data_labels(files):
    data = set()
    for f in files:
        L = open(f, errors="replace").read().split("\n")
        for i, l in enumerate(L):
            if not l or l[0] in "\t ;": continue
            m = LAB.match(l)
            if not m: continue
            rest = code(l[m.end():]).strip(); k = i + 1
            while not rest and k < len(L):
                rest = code(L[k]).strip(); k += 1
            if DC.match(rest): data.add(m.group(1))
    return data

def split_ops(ops):
    depth, cur, parts = 0, "", []
    for ch in ops:
        if ch == "(": depth += 1
        elif ch == ")": depth -= 1
        if ch == "," and depth == 0: parts.append(cur); cur = ""
        else: cur += ch
    parts.append(cur)
    return parts

def scan(files, data):
    direct, viaptr = [], []
    for f in files:
        L = [code(x) for x in open(f, errors="replace").read().split("\n")]
        for i, l in enumerate(L):
            if not l or l[0] not in "\t ": continue
            c = l.strip()
            if not c: continue
            mn, _, ops = c.replace("\t", " ").partition(" ")
            base = mn.lower().split(".")[0]
            ops = ops.strip()
            # (1) direct write to a data label
            if base in WR:
                parts = split_ops(ops)
                if len(parts) >= 2 or base in SINGLE:
                    dst = parts[-1].strip()
                    if not dst.startswith("#") and not re.fullmatch(r'[ad]\d|sp|\(a\d\)\+?|-\(a\d\)', dst):
                        for t in IDENT.findall(dst):
                            if t in data:
                                direct.append((f, i + 1, t, c)); break
            # (2) lea data,aN ... write through aN
            m = LEA.match(c)
            if m and m.group(1) in data:
                lbl, reg = m.group(1), m.group(2)
                for j in range(i + 1, min(i + 25, len(L))):
                    t = L[j].strip()
                    if not t: continue
                    if re.match(r'^(rts|rte|jmp|bra)', t, re.I): break
                    mm = re.match(r'^(\w+)(?:\.\w)?\s+(.*)$', t)
                    if not mm: continue
                    mn2, o2 = mm.group(1).lower(), mm.group(2)
                    if mn2 == "lea" and o2.endswith("," + reg): break
                    dst = o2.rsplit(",", 1)[-1].strip()
                    if mn2 in WR and re.fullmatch(r'-?\$?\w*\(%s(?:,\w+(?:\.\w)?)?\)\+?|\(%s\)\+?' % (reg, reg), dst):
                        viaptr.append((f, i + 1, lbl, reg, t)); break
    return direct, viaptr

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__); sys.exit(1)
    files = collect(sys.argv[1:])
    data = data_labels(files)
    direct, viaptr = scan(files, data)
    print(f"{len(files)} archivos, {len(data)} etiquetas de datos dc/ds")
    for f, ln, lbl, c in direct:
        print(f"[directo ] {f}:{ln}  {lbl}   <- {c}")
    for f, ln, lbl, reg, t in viaptr:
        print(f"[puntero ] {f}:{ln}  lea {lbl},{reg}   luego: {t}")
    print(f"TOTAL: {len(direct)} directos, {len(viaptr)} por puntero")
    sys.exit(1 if (direct or viaptr) else 0)
