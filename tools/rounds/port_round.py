#!/usr/bin/env python3
"""Ports one round into the unified ROM source (src/MD Port/Zones/<R>.asm + <R>/_symbols.txt).
   usage (repo root):  python3 tools/rounds/port_round.py R12B [--fresh]
 --fresh  re-extracts from the MMD first (extract_round.py); without it the existing zone file is post-processed.
 steps: extract -> drop per-round ObjectIndex (global now) -> BG chunks (Demo) -> palette-cycle fall-through ->
        PLC lists + content-linked art (link_assets.py) -> trim dead code (trim_round.py)"""
import sys, os, re, subprocess
R = sys.argv[1]; FRESH = '--fresh' in sys.argv
env = dict(os.environ, CCZ='/home/claude/work/mdport/src/Level/', SRC=os.path.abspath('src'))
def run(*a, cwd=None): subprocess.run(a, check=True, env=env, cwd=cwd)
if FRESH: run('python3', '../tools/rounds/extract_round.py', R, cwd='src')
sym = f'src/MD Port/Zones/{R}/_symbols.txt'
s = open(sym).read(); s = re.sub(r'^ObjectIndex=.*\n', '', s, flags=re.M); open(sym, 'w').write(s)
f = f'src/MD Port/Zones/{R}.asm'; t = open(f).read()
act, tz = R[2], {'A': 'Present', 'B': 'Past', 'C': 'Good Future', 'D': 'Bad Future'}[R[3]]
m = re.search(rf'{R}_LevelChunks:\n\tincbin\t"[^"]+"\n', t)
if m and f'{R}_LevelDemo:' not in t:
    t = t[:m.end()] + f'{R}_LevelDemo:\n\tincbin\t"Level/Palmtree Panic/Data/Level/Demo (Act {act} {tz}).bin"\n' + t[m.end():]
m = re.search(rf'(\tlea\s+{R}_PalCycleColors\d\.l, a2\n)(?={R}_PalCycleScript1:)', t)
if m: t = t[:m.end()] + '\tjmp     CycleColor\n' + t[m.end():]
open(f, 'w').write(t)
run('python3', 'tools/rounds/link_assets.py', R)
run('python3', 'tools/rounds/trim_round.py', R)
