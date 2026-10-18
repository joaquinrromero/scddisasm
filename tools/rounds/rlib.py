"""Helpers to read the per-round generated sources (tools/mmd2md output) as routines."""
import re, os, collections
CCZ = os.environ.get("CCZ", "/home/claude/ccz/src/Level/")
ZN = {1: "Palmtree Panic", 3: "Collision Chaos", 4: "Tidal Tempest", 5: "Quartz Quadrant", 6: "Wacky Workbench", 7: "Stardust Speedway", 8: "Metallic Madness"}
TN = {"A": "Present", "B": "Past", "C": "Good Future", "D": "Bad Future"}
AUTO = re.compile(r'\b(?:loc|locret|sub|dat|off|byte|word|unk|dword|stru|jpt|asc|Obj\d+|Hud|Data)_[0-9A-Fa-f]{6}\b')
LIT = re.compile(r'(?<![\w$])\$2[0-3][0-9A-Fa-f]{4}\b')
INTERNAL = re.compile(r'^(?:loc|locret)_[0-9A-Fa-f]+$')          # loc_ labels belong to the routine they sit in

def round_path(r, generated=True):
    m = re.match(r"R(\d)(\d)([ABCD])", r); z, a, t = int(m[1]), m[2], m[3]
    p = f"{CCZ}{ZN[z]}/Act {a} {TN[t]}"
    return p + (" (Generated).asm" if (generated and os.path.exists(p + " (Generated).asm")) else ".asm")

def norm(line, labs=frozenset()):
    t = re.sub(r'\s+', ' ', line.split(";")[0]).strip()
    t = LIT.sub("@", AUTO.sub("@", t))
    if labs: t = re.sub(r'(?<![\w.$#@])[A-Za-z_]\w*', lambda m: "@" if m.group(0) in labs else m.group(0), t) if False else re.sub(r'[A-Za-z_]\w*', lambda m: "@" if m.group(0) in labs else m.group(0), t)
    return t

class Routine:
    __slots__ = ("name", "lines", "start", "labs")
    def __init__(s, name, start): s.name = name; s.lines = []; s.start = start; s.labs = frozenset()
    @property
    def sig(s): return tuple(x for x in (norm(l, s.labs) for l in s.lines) if x)
    def is_auto(s): return bool(AUTO.fullmatch(s.name)) or s.name.startswith("__head")

def routines(path):
    """ordered list of Routine; a routine starts at every global label that is not loc_*"""
    out = []; cur = Routine("__head", 0); out.append(cur)
    for i, l in enumerate(open(path, errors="replace").read().replace("\r", "").split("\n")):
        m = re.match(r'^([A-Za-z_]\w*):', l)
        if m and not INTERNAL.match(m.group(1)):
            cur = Routine(m.group(1), i); out.append(cur)
        cur.lines.append(l)
    labs = frozenset(m.group(1) for r in out for l in r.lines for m in [re.match(r'^([A-Za-z_]\w*):', l)] if m)
    for r in out: r.labs = labs
    return out

def address_map(rnd, ccz_src="/home/claude/ccz/src", wine="/usr/lib/wine/wine"):
    """label -> address of every label of the round, from an asm68k listing of its own Mega Drive build"""
    import subprocess, json
    cache = f"/tmp/addrmap_{rnd}.json"
    if os.path.exists(cache): return json.load(open(cache))
    env = dict(os.environ, WINEDEBUG="-all")
    subprocess.run([wine, "../bin/asm68k.exe", "/p", "/o", "ae-,l.,ow+", "/e", "REGION=1", "/e", "DEMO=0", "/e", "MDPORT=1",
                    f"MD Port\\Main ({rnd}).asm,", f"/tmp/{rnd}.bin,", ",", f"/tmp/{rnd}.lst"], cwd=ccz_src, capture_output=True, env=env)
    out = {}
    for l in open(f"/tmp/{rnd}.lst", errors="replace").read().replace("\r", "").split("\n"):
        m = re.match(r'^([0-9A-F]{8})\s+(?:[0-9A-F]{4}\s?)*\s*([A-Za-z_]\w*):', l)
        if m and 0x200000 <= int(m.group(1), 16) < 0x240000: out[m.group(2)] = int(m.group(1), 16)
    json.dump(out, open(cache, "w")); return out
