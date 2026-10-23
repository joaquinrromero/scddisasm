#!/usr/bin/env python3
"""Merges byte-identical per-zone data tables: the first zone (order Present, Past, GoodFuture, BadFuture, R12B, R12A,
R12C, R12D) keeps the table, later zones get an alias in "MD Port/Zones/Zone Aliases.txt" (Zone.Symbol=Label) and their
copy is deleted from the zone file.  Idempotent.   Uso (desde src/): python3 ../tools/dedupe_zones.py && python3 ../tools/make_zone_table.py"""
import re, os, glob, hashlib, sys
sys.argv = [sys.argv[0]]
src = open("../tools/make_zone_table.py").read().split("out = [")[0]   # reuse syms/block()
exec(src)
ORDER = ["Present", "Past", "GoodFuture", "BadFuture", "R12B", "R12A", "R12C", "R12D"]
CODE = {"InitLevelScroll", "LevelScroll", "PaletteCycle", "LevelPaletteID"}   # LevelPaletteID: aliasing it changes the picture (indexed beyond its 2 bytes), keep per zone | set(os.environ.get("DEDUPE_SKIP","").split(","))
def files(z):
    if z == "Present": return [f for f in glob.glob("Level/Palmtree Panic/**/*.asm", recursive=True) if not re.search(r"Past|Good Future|Bad Future|Act [23]", f)]
    return glob.glob(f"MD Port/Zones/{z}/*.asm") + glob.glob(f"MD Port/Zones/{z}.asm")
SEG = lambda label: re.compile(rf"^{re.escape(label)}:[^\n]*\n(.*?)(?=^(?!\w*?(?:loc|locret|byte|word|unk|off|stru|asc|dword)_)[A-Za-z_.]\w*:|\Z)", re.S | re.M)
def find(z, label):
    for f in files(z):
        t = open(f).read().replace("\r", "")
        m = SEG(label).search(t)
        if m: return f, t, m
    return None
def norm(body, z):
    body = re.sub(r";[^\n]*", "", body)
    if z != "Present": body = re.sub(rf"^{z}_", "", body)   # only the table's own label; references must match exactly
    return re.sub(r"\s+", " ", body).strip()
tsym = {s: i for i, s in enumerate(syms)}
canon = {}; alias = {}
for z in ORDER:
    b = block(z) if z != "Present" else {s: s for s in syms}
    if not b: continue
    for s in syms:
        if s in CODE or b[s].startswith("+"): continue
        label = b[s]
        r = find(z, label)
        if not r: continue
        f, t, m = r
        body = norm(m.group(1), z)
        if not body or re.search(r"\b(move|lea|bsr|jsr|bra|rts|jmp|cmp|add|sub|tst|dbf|b[a-z]{2})(\.[bwls])?\s", body[:400]): continue
        key = (s, body)
        if key in canon and canon[key] != label and (z == "Present" or label.startswith(z + "_")):
            alias[f"{z}.{s}"] = canon[key]
            if z != "Present" and label.startswith(z + "_"):
                open(f, "w", newline="\n").write(t[:m.start()] + "\teven\n" + t[m.end():])
        else: canon.setdefault(key, label)
dead = {}   # deleted own label -> canonical label
for k, v in alias.items():
    z, s = k.split("."); dead[(block(z) or {}).get(s)] = v
for z in ORDER:                      # other zones that pointed (MAP) at a deleted label follow it
    b = block(z) if z != "Present" else None
    for s in (b or {}):
        if b[s] in dead and f"{z}.{s}" not in alias: alias[f"{z}.{s}"] = dead[b[s]]
old = {}
if os.path.exists("MD Port/Zones/Zone Aliases.txt"):
    old = dict(l.split("=", 1) for l in open("MD Port/Zones/Zone Aliases.txt").read().split("\n") if "=" in l)
old.update(alias)
open("MD Port/Zones/Zone Aliases.txt", "w", newline="\n").write("\n".join(f"{k}={v}" for k, v in sorted(old.items())) + "\n")
print(len(alias), "new aliases,", len(old), "total")
