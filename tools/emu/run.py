#!/usr/bin/env python3
"""
Bateria de pruebas en emulador en UNA sola llamada (Genesis Plus GX headless + arnes h.c).

  run.py check   ROM [--frames N] [--snaps a,b,c] [--no-play] [--watch Name,...]
  run.py compare REF NEW [--frames N]

check   : juega N frames (entrada simulada), cuenta escrituras a ROM, vuelca estado de RAM clave y arma
          UN png con los snapshots (out/<rom>_grid.png).
compare : hash de pantalla cada 250 frames + frames distintos frame a frame + clasificacion de la RAM distinta.
Requiere el core con romw_hook.patch (escrituras a ROM) y 'make -f Makefile.libretro'. Rutas por env:
  CORE (core .so), H (binario del arnes), SRC (carpeta src del disassembly), WINE.
"""
import os, sys, subprocess, struct, re, argparse, tempfile, collections
from PIL import Image
H    = os.environ.get("H", "/home/claude/h2")
CORE = os.environ.get("CORE", "/home/claude/gpgx/genesis_plus_gx_libretro.so")
SRC  = os.environ.get("SRC", "/home/claude/scddisasm/src")
WINE = os.environ.get("WINE", "/usr/lib/wine/wine")

def run_h(rom, frames, play, snaps="", hashevery=0, out=None, pcs=0):
    out = out or tempfile.mkdtemp(prefix="emu_")
    env = dict(os.environ, OUT=out, CORE=CORE, SNAPS=snaps, HASHEVERY=str(hashevery), PCSAMPLES=str(pcs))
    p = subprocess.run([H, rom, str(frames), "1" if play else "0"], capture_output=True, text=True, env=env)
    hashes = [l.split()[1:] for l in p.stdout.splitlines() if l.startswith("H ")]
    romw = [l for l in p.stderr.splitlines() if l.startswith("ROMW")]
    run_h.pcs = [int(l.split()[1]) for l in p.stdout.splitlines() if l.startswith("P ")]
    return out, hashes, romw

def symbols(names):
    """RAM/rs symbol values via a throw-away assembly (asm68k) of the port's definitions."""
    probe = os.path.join(SRC, "_symprobe.asm")
    open(probe, "w").write('\tinclude\t"MD Port/Main.asm"\nSYMPROBE:\n' + "".join(f"\tdc.l\t{n}\n" for n in names))
    env = dict(os.environ, WINEDEBUG="-all")
    try:
        r = subprocess.run([WINE, "../bin/asm68k.exe", "/p", "/o", "ae-,l.,ow+", "/e", "REGION=1", "/e", "DEMO=0", "/e", "MDPORT=1",
                            "_symprobe.asm,", "/tmp/_symprobe.bin"], cwd=SRC, capture_output=True, text=True, env=env)
        d = open("/tmp/_symprobe.bin", "rb").read()[-4 * len(names):]
        return dict(zip(names, struct.unpack(">%dL" % len(names), d)))
    finally:
        for f in ("_symprobe.asm", "_symprobe.lst"):
            try: os.remove(os.path.join(SRC, f))
            except OSError: pass

def labels():
    """ROM labels (addr,name) from the port listing, sorted."""
    out = []
    for l in open(os.path.join(SRC, "MD Port/Main.lst"), errors="replace").read().replace("\r", "").split("\n"):
        m = re.match(r'^([0-9A-F]{8})\s+([A-Za-z_]\w*):', l)
        if m and int(m.group(1), 16) < 0x400000: out.append((int(m.group(1), 16), m.group(2)))
    return sorted(out)

def sym(pc, labs):
    best = None
    for a, n in labs:
        if a <= pc: best = (a, n)
        else: break
    return f"{best[1]}+{pc - best[0]:#x}" if best else f"{pc:#x}"

class Ram:
    def __init__(s, path): s.d = open(path, "rb").read()
    def b(s, a): return s.d[(a & 0xFFFF) ^ 1]
    def w(s, a): return s.b(a) << 8 | s.b(a + 1)
    def l(s, a): return s.w(a) << 16 | s.w(a + 2)

def grid(paths, outpng, scale=1):
    ims = [Image.open(p).convert("RGB") for p in paths]
    w, h = ims[0].size; cols = min(3, len(ims)); rows = (len(ims) + cols - 1) // cols
    g = Image.new("RGB", (w * cols, h * rows))
    for i, im in enumerate(ims): g.paste(im, ((i % cols) * w, (i // cols) * h))
    if scale != 1: g = g.resize((g.width // scale, g.height // scale))
    g.save(outpng); return outpng

def cmd_check(a):
    snaps = a.snaps or ",".join(str(int(a.frames * f)) for f in (0.02, 0.1, 0.5, 1.0))
    name = os.path.splitext(os.path.basename(a.rom))[0]
    out, _, romw = run_h(a.rom, a.frames, not a.no_play, snaps, pcs=a.pc)
    last = int(snaps.split(",")[-1])
    ram = Ram(f"{out}/r_{last}.bin")
    dumps = [x.split(":") for x in a.dump.split(",")] if a.dump else []
    S = symbols([d[0] for d in dumps] + ["timeZone", "gameMode", "levelChunksPtr", "zoneVars", "objects", "oSize", "lives", "rings", "time", "score"] + (a.watch.split(",") if a.watch else []))
    tz = ram.b(S["timeZone"]); objs = [ram.b(S["objects"] + i * S["oSize"]) for i in range(10)]
    uniq = collections.Counter((l.split()[2], l.split()[4]) for l in romw)
    print(f"ROM {name}: frames={a.frames} play={not a.no_play}")
    print(f"  escrituras a ROM: {len(romw)}" + (f"  (top: {uniq.most_common(3)})" if romw else ""))
    print(f"  timeZone={tz:#04x} gameMode={ram.b(S['gameMode']):#04x} lives={ram.b(S['lives'])} rings={ram.w(S['rings'])} score={ram.l(S['score'])} time={ram.l(S['time']):#010x}")
    print(f"  levelChunksPtr={ram.l(S['levelChunksPtr']):#08x}  objetos[0..9].ID={objs}")
    for n in (a.watch.split(",") if a.watch else []): print(f"  {n}={ram.l(S[n]):#010x}")
    for n, ln in dumps: print(f"  {n}[{ln}]=" + " ".join("%02X" % ram.b(S[n] + i) for i in range(int(ln))))
    if a.stack:
        labs = labels(); top = ram.d; words = []
        for off in range(0xFFFC, 0xFF00 - 4, -4):
            v = ram.l(0xFF0000 + off)
            if 0x200 <= v < 0x80000 and off != 0xFFFC: words.append(f"[{0xFF0000+off:06X}]={sym(v, labs)}")
        print("  stack (direcciones de ROM, de arriba abajo): " + "  ".join(words[:14]))
    if a.pc:
        labs = labels(); c = collections.Counter(sym(p, labs) for p in run_h.pcs)
        print("  PC (últimos %d frames): " % a.pc + ", ".join(f"{k} x{v}" for k, v in c.most_common(6)))
    png = grid([f"{out}/s_{s}.ppm" for s in snaps.split(",")], f"{out}/{name}_grid.png")
    print(f"  grid: {png}")

def cmd_compare(a):
    out1, h1, r1 = run_h(a.ref, a.frames, True, hashevery=250)
    out2, h2, r2 = run_h(a.new, a.frames, True, hashevery=250)
    d250 = sum(1 for x, y in zip(h1, h2) if x != y)
    f1 = run_h(a.ref, min(a.frames, 3000), True, hashevery=1)[1]; f2 = run_h(a.new, min(a.frames, 3000), True, hashevery=1)[1]
    df = [x[0] for x, y in zip(f1, f2) if x != y]
    print(f"checkpoints/250: {len(h1)}  distintos: {d250} | frame a frame (3000): {len(df)} distintos | ROMW ref={len(r1)} nueva={len(r2)}")
    last = a.frames
    for o, rom in ((out1, a.ref), (out2, a.new)):
        run_h(rom, last, True, snaps=str(last), out=o)
    A, B = Ram(f"{out1}/r_{last}.bin").d, Ram(f"{out2}/r_{last}.bin").d
    diff = sorted(((i ^ 1) | 0xFF0000) for i in range(65536) if A[i] != B[i])
    cls = collections.Counter("objetos" if 0xFFD000 <= x < 0xFFF000 else "stack" if x >= 0xFFFFC0 or 0xFFFF00 <= x else "otros" for x in diff)
    print(f"RAM distinta en frame {last}: {len(diff)} bytes {dict(cls)}  otros={[hex(x) for x in diff if not (0xFFD000 <= x < 0xFFF000 or x >= 0xFFFF00)][:12]}")

if __name__ == "__main__":
    ap = argparse.ArgumentParser(); sp = ap.add_subparsers(dest="cmd", required=True)
    c = sp.add_parser("check"); c.add_argument("rom"); c.add_argument("--frames", type=int, default=3000); c.add_argument("--snaps")
    c.add_argument("--no-play", action="store_true"); c.add_argument("--watch"); c.add_argument("--dump", help="Name:len,...  (hex de regiones de RAM)"); c.add_argument("--stack", action="store_true", help="muestra direcciones de ROM en el stack"); c.add_argument("--pc", type=int, default=0, help="muestrea el PC en los ultimos N frames")
    d = sp.add_parser("compare"); d.add_argument("ref"); d.add_argument("new"); d.add_argument("--frames", type=int, default=7000)
    a = ap.parse_args(); (cmd_check if a.cmd == "check" else cmd_compare)(a)
