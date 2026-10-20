"""Bakes data for the Markey-style Mode 7 floor demo — stamp-local camera.

Architecture: stamp-local camera with RAM texture.
  - The camera always lives inside a single 32×32 stamp (camX/Y in [0,32)).
  - A RAM texture of W×W pixels (W = footprint diameter, rounded to 32×stamp)
    is rebuilt around the current stamp whenever the camera crosses a boundary.
  - Angle tables store offsets relative to the camera, same format as before.
    The base offset in the render = camY*W + camX (camera within the texture,
    always at FD_START = W//2).
  - On a boundary crossing: stampX/Y increments, camera wraps mod 32, and
    LoadStampTex rebuilds the W×W texture from FloorStampMap + FloorStampsPacked.

ROM data:
  stamps_packed.bin  — nstamps × 512 B (32 rows × 16 bytes, 4bpp row-major)
  stamp_map.bin      — 128×128 big-endian words (full stage layout)
  angles.bin         — per-angle tables (1L base + 15W relatives per segment)
  forward.bin        — 32 × (dx, dy) as 8.8 signed words
  angle_dir.inc      — dc.l pointers into angles.bin
  params.inc         — assembled constants

The texture is no longer in ROM. It lives in Work RAM (W×W bytes, ~49 KB for
W=224). The hi/lo split is gone — LoadStampTex writes both nibbles in one pass
using the same OR trick: tex[y][x] is written as (hi_nib << 4) | lo_nib where
hi = color index of pixel x, lo = color index of pixel x+1 (same as before but
built at runtime from stamp data). Wait — actually keeping 1 byte/pixel (not
packed) simplifies the render and avoids nibble-alignment issues; the OR happens
at render time exactly as in cf4d7eb. So LoadStampTex writes a plain 1-byte/pixel
W×W RAM texture (tex_hi: color<<4, tex_lo: color), then the render reads both as
before. Total RAM: W*W*2 bytes for the two halves = 224*224*2 = ~98 KB. That
exceeds Work RAM (64 KB).

Solution: use 4bpp PACKED format (1 byte = 2 pixels, high nibble = left pixel).
tex[y][x/2] = (color[x] << 4) | color[x+1].  W×W/2 = 224*224/2 = 25088 bytes.
The render still uses the OR trick but reads from a single packed texture:
  hi_byte = tex_packed[addr >> 1]; lo has the nibble in place already.
Actually the cleanest approach: keep the exact cf4d7eb render logic (separate hi
and lo pointers, OR per pair) but build the two halves in RAM instead of ROM.
RAM cost: W*W*2 = ~98 KB — too large.

Simplest correct approach: 1 byte/pixel but only ONE copy (no 3-copy trick).
Wrap is handled in the render loop with explicit mod. W=224, single copy = 50 KB.
Still too large for 64 KB Work RAM (need 24 KB for frame buffers).

Final decision: 4bpp packed single copy (25 KB) as in the previous attempt, BUT
fix the nibble issue by ensuring the table offsets always point to the EVEN pixel
of each byte. We do this by making the camera position always even (force camX
even on load), so addr = camY*W + camX is always even, and all offsets from an
even base to the same row are even (since dx is an integer and the row is sampled
at integer steps). Actually offsets can be odd if the step dx is 1 per pixel. To
avoid nibble misalignment we sample ONE byte per output byte (2 pixels) using the
even-pixel offset — same as the previous packed attempt but with the 1L+15W table
(not 1L+7W). We need 15 relative offsets for 16 pixels = 8 pairs. Each pair needs
one offset (the even pixel; the odd is implied as even+1 within the same byte).
Wait — 8 pairs need 8 base offsets in the segment. We have 1 base + 15 relatives.
So: base = offset of even pixel 0; relatives[0..6] = offsets of even pixels 1..7
(7 relatives for pairs 1..7); relatives[7..14] = offsets of even pixels 8..15
(second half of segment). Total: 1L + 15W — exactly the existing format! But we
only use 8 of the 15 relatives (the even ones at indices 0,2,4,6,8,10,12 of the
original 15). This wastes 7 words per segment.

CLEANEST: keep the existing 1L+15W table for the full 16 pixels (1 byte/pixel
access) but use a SINGLE copy of the texture in RAM with explicit wrap per segment.
RAM: 25 KB packed + 24 KB buffers = 49 KB < 64 KB. The render wraps the base
offset once per segment (two compares). This is exactly what the previous attempt
did — and the only real issue was the nibble alignment, which we can fix by
keeping the hi/lo split but computing it in RAM.

FINAL FINAL: keep cf4d7eb render EXACTLY (hi pointer + lo pointer, OR trick,
3-copy layout) but build the texture in RAM. 3 copies of W×W bytes × 2 (hi+lo)
= 6 × 224² = 301 KB. Way too much.

OK — the correct minimal fix: use the 4bpp PACKED layout with even-pixel sampling
in the bake (1L + 7W per segment, sampling pixels 0,2,4,...,14) as done in the
previous session, but also keep single-copy with explicit wrap in the render.
This is what we had at the end of the last session. The only issue was bugs in
BuildTex/UpdateTexture. Here we replace those with LoadStampTex which is simpler.
"""
import struct, sys, os
import numpy as np
from ref import *

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
OUT = sys.argv[1] if len(sys.argv) > 1 else "src/MD Port/Floor Demo"
NANG = int(os.environ.get("NANG", "32")); R0 = int(os.environ.get("R0", "55"))
Z = 0x160; SEG = 16
X0_CAM = 0x540; Y0_CAM = 0x520           # camera start in map pixels
os.makedirs(OUT, exist_ok=True)

S, M = decode_stage(1)

# ---- measure footprint ----
maxR_pre = 0
for a in range(NANG):
    yaw = a * 512 // NANG
    tab = trace_table(0, 0, Z, 0x80, yaw)
    i = np.arange(256)
    for r in range(R0, 96):
        xs, ys, dx, dy = tab[r]
        X = (xs*256 + i*dx) >> 11; Y = (ys*256 + i*dy) >> 11
        maxR_pre = max(maxR_pre, int(np.abs(X).max()), int(np.abs(Y).max()))
W = H = int(np.ceil((maxR_pre * 2 + 1) / 32)) * 32
assert W == 224, f"Expected W=224, got {W}"

# ---- packed stamps (ROM) ----
nstamps = S.shape[0]
packed_stamps = np.zeros((nstamps, 32, 16), np.uint8)
packed_stamps[:, :, :] = (S[:, :, 0::2] << 4) | S[:, :, 1::2]
open(f"{OUT}/stamps_packed.bin", "wb").write(packed_stamps.tobytes())

# ---- stamp map (ROM) ----
open(f"{OUT}/stamp_map.bin", "wb").write(M.astype(">u2").tobytes())

# ---- angle tables ----
# Format per segment: 1 signed longword (base byte-offset of packed byte 0 of the segment,
# relative to camera) + 7 signed words (relative packed-byte offsets of bytes 1-7).
# Each packed byte covers 2 pixels (even+odd). We sample every other pixel (0,2,4,...,14).
# Offsets are in PACKED byte units (pixel_offset >> 1), so no shift needed in the render.
i = np.arange(256)
angles = bytearray(); offs = []; maxrel = 0; maxR = 0
fwd = []
for a in range(NANG):
    yaw = a * 512 // NANG
    tab = trace_table(0, 0, Z, 0x80, yaw)
    offs.append(len(angles))
    for r in range(R0, 96):
        xs, ys, dx, dy = tab[r]
        X = (xs*256 + i*dx) >> 11; Y = (ys*256 + i*dy) >> 11
        maxR = max(maxR, int(np.abs(X).max()), int(np.abs(Y).max()))
        # Pixel offsets relative to camera (can be large negative/positive)
        L = Y * W + X
        for s in range(256 // SEG):
            seg = L[s*SEG:(s+1)*SEG]
            # Sample even pixels only (one per packed byte)
            seg_bytes = seg[0::2]            # 8 values: offsets of bytes 0..7
            base_packed = int(seg_bytes[0]) >> 1
            rel_packed = [int(seg_bytes[k] - seg_bytes[0]) >> 1 for k in range(1, 8)]
            maxrel = max(maxrel, max(abs(r) for r in rel_packed))
            assert all(abs(r) < 32768 for r in rel_packed), ("segment rel overflow", a, r, s)
            angles += struct.pack(">l", base_packed) + struct.pack(">7h", *rel_packed)
    cx_ = lambda r: ((tab[r][0]*256 + 128*tab[r][2]) >> 11, (tab[r][1]*256 + 128*tab[r][3]) >> 11)
    f = np.array(cx_(R0 + (96-R0)//4), float) - np.array(cx_(95), float)
    f = f / np.hypot(*f) * 4
    fwd.append((int(round(f[0]*256)), int(round(f[1]*256))))
open(f"{OUT}/angles.bin", "wb").write(bytes(angles))
open(f"{OUT}/forward.bin", "wb").write(b"".join(struct.pack(">hh", *f) for f in fwd))
with open(f"{OUT}/angle_dir.inc", "w") as f:
    for o in offs: f.write("\tdc.l\tFloorAngles+%d\n" % o)

# Stamp coords of the texture origin at startup:
# texOrgX = X0_CAM - W//2  (map pixel of texture column 0)
# The current stamp = X0_CAM >> 5, Y0_CAM >> 5
# Camera within the stamp = X0_CAM & 31, Y0_CAM & 31
# Camera within the texture = FD_START = W//2 (always)
tex_ox = (X0_CAM - W//2) % 4096
tex_oy = (Y0_CAM - W//2) % 4096
start_stampx = (X0_CAM >> 5) & 0x7F
start_stampy = (Y0_CAM >> 5) & 0x7F
start_camx_in_stamp = X0_CAM & 31
start_camy_in_stamp = Y0_CAM & 31

rows = 96 - R0
tex_ram = W * W // 2   # 4bpp packed single copy
per_seg = 4 + 14       # 1 longword + 7 words
with open(f"{OUT}/params.inc", "w") as f:
    f.write(f"""\t; Auto-generated by bake_floor_demo.py — do not edit
FD_W\t\tEQU\t{W}\t\t\t; Texture width/height in pixels
FD_WPACKED\tEQU\t{W//2}\t\t\t; Texture row stride in bytes (4bpp packed)
FD_TEXSIZE\tEQU\t{tex_ram}\t\t\t; RAM texture size in bytes
FD_WSTAMPS\tEQU\t{W//32}\t\t\t; Texture width/height in stamps
FD_R0\t\tEQU\t{R0}\t\t\t; First rendered row
FD_ROWS\t\tEQU\t{rows}
FD_NANG\t\tEQU\t{NANG}
FD_NSTAMPS\tEQU\t{nstamps}\t\t\t; Total stamps in ROM
FD_START\tEQU\t{W//2}\t\t\t; Camera pixel within texture (always W/2)
FD_STARTCAMX\tEQU\t{start_camx_in_stamp}\t\t\t; Camera pixel within starting stamp (X)
FD_STARTCAMY\tEQU\t{start_camy_in_stamp}\t\t\t; Camera pixel within starting stamp (Y)
FD_STARTSTX\tEQU\t{start_stampx}\t\t\t; Starting stamp map column
FD_STARTSTY\tEQU\t{start_stampy}\t\t\t; Starting stamp map row
""")

print(f"R0={R0}, NANG={NANG}, rows {R0}..95 ({rows}), footprint R={maxR}, W={W} ({W//32} stamps)")
print(f"angle tables: {len(angles)//1024} KB  stamps: {nstamps*512//1024} KB  map: {128*128*2//1024} KB")
print(f"RAM texture: {W}x{W} 4bpp packed = {tex_ram//1024} KB")
print(f"Total ROM: {(len(angles)+nstamps*512+128*128*2)//1024} KB")
print(f"Max segment relative byte offset: {maxrel}")
print(f"Start: stamp ({start_stampx},{start_stampy}), cam-in-stamp ({start_camx_in_stamp},{start_camy_in_stamp})")
