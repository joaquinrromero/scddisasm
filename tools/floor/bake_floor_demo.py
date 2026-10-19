"""Bakes the data for the Markey-style Mode 7 floor demo (stage 1).

Flat texture (1 byte/pixel) of an 832x832 region of the stage map, plus, for NANG yaw angles,
the camera-relative texel offsets of every pixel of rows R0..95 (exact, from the original trace table
formulas with the camera at the origin: the camera is at integer pixels, so X = cam + X_rel exactly).
"""
import struct, sys, os
import numpy as np
from ref import *

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
OUT = sys.argv[1] if len(sys.argv) > 1 else "src/MD Port/Floor Demo"
NANG = int(os.environ.get("NANG", "32")); R0 = int(os.environ.get("R0", "25"))
# W is computed after measuring the footprint; for the first pass use a safe upper bound
# so we can measure R, then re-run with the exact W. (In practice we just measure first.)
Z = 0x160; SEG = 16
# Map origin for camera start: centre of the first 32x32-stamp block of stage 1 map
# We place the camera at integer map coordinates (X0, Y0).
X0_CAM = 0x540; Y0_CAM = 0x520           # camera start in map pixels (same as before)
os.makedirs(OUT, exist_ok=True)

S, M = decode_stage(1)

# ---- measure footprint R (maximum |rel_x|, |rel_y| from the camera) ----
maxR_pre = 0
for a in range(NANG):
    yaw = a * 512 // NANG
    tab = trace_table(0, 0, Z, 0x80, yaw)
    i = np.arange(256)
    for r in range(R0, 96):
        xs, ys, dx, dy = tab[r]
        X = (xs*256 + i*dx) >> 11; Y = (ys*256 + i*dy) >> 11
        maxR_pre = max(maxR_pre, int(np.abs(X).max()), int(np.abs(Y).max()))
# W must cover ±R from the camera; round up to a multiple of 32 for clean stamp alignment
W = H = int(np.ceil((maxR_pre * 2 + 1) / 32)) * 32

# ---- flat texture with wrap: W×W region of the map, tiling infinitely ----
# The camera start is at (W//2, W//2) in texture coordinates.
# Map coords of texture pixel (tx, ty): map_x = X0_CAM - W//2 + tx  (mod 4096)
#                                        map_y = Y0_CAM - W//2 + ty  (mod 4096)
tex_ox = (X0_CAM - W//2) % 4096         # map pixel of texture column 0
tex_oy = (Y0_CAM - W//2) % 4096         # map pixel of texture row 0
tex = np.zeros((H, W), np.uint8)
for cy in range(H // 32):
    for cx in range(W // 32):
        # map stamp coords (with wrap)
        msx = ((tex_ox >> 5) + cx) % 128
        msy = ((tex_oy >> 5) + cy) % 128
        raw = int(M[msy, msx]); sid = (raw & 0x7FF) >> 2
        if sid == 0 or sid >= S.shape[0]: continue
        v, u = np.mgrid[0:32, 0:32]
        su, sv = stamp_pixel_xform(u, v, np.full((32, 32), raw))
        tex[cy*32:cy*32+32, cx*32:cx*32+32] = S[sid][sv, su]

# Export 3 vertical copies so the renderer can use the middle copy as its base
# and offsets of ±W will always land in a valid copy (no conditional wrap in the hot loop).
tex3 = np.tile(tex, (3, 1))  # shape (3W, W)
open(f"{OUT}/tex_lo.bin", "wb").write(tex3.tobytes())
open(f"{OUT}/tex_hi.bin", "wb").write((tex3 << 4).astype(np.uint8).tobytes())

# ---- per-angle tables ----
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
        L = Y * W + X
        for s in range(256 // SEG):
            seg = L[s*SEG:(s+1)*SEG]; rel = seg[1:] - seg[0]
            maxrel = max(maxrel, int(np.abs(rel).max()))
            assert np.abs(rel).max() < 32768, ("segment span too large", a, r, s)
            angles += struct.pack(">l", int(seg[0])) + struct.pack(">15h", *[int(x) for x in rel])
    # forward direction (far - near along the central column), 4 px per step, 8.8
    cx_ = lambda r: ((tab[r][0]*256 + 128*tab[r][2]) >> 11, (tab[r][1]*256 + 128*tab[r][3]) >> 11)
    f = np.array(cx_(40), float) - np.array(cx_(95), float); f = f / np.hypot(*f) * 4
    fwd.append((int(round(f[0]*256)), int(round(f[1]*256))))
open(f"{OUT}/angles.bin", "wb").write(bytes(angles))
open(f"{OUT}/forward.bin", "wb").write(b"".join(struct.pack(">hh", *f) for f in fwd))
with open(f"{OUT}/angle_dir.inc", "w") as f:
    for o in offs: f.write("\tdc.l\tFloorAngles+%d\n" % o)
rows = 96 - R0; per_angle = rows * (256 // SEG) * (4 + 30)
tex3size = W * H * 3   # three vertical copies of the texture
with open(f"{OUT}/params.inc", "w") as f:
    f.write(f"""FD_W\tEQU\t{W}\t\t\t; Flat texture width/height
FD_TEXSIZE\tEQU\t{W*H}\t\t\t; Single-copy size (base ptr uses middle copy = +FD_TEXSIZE)
FD_TEX3SIZE\tEQU\t{tex3size}\t\t\t; Total stored size (3 vertical copies each of hi and lo)
FD_R0\tEQU\t{R0}\t\t\t; First baked row
FD_ROWS\tEQU\t{rows}
FD_NANG\tEQU\t{NANG}
FD_START\tEQU\t{W//2}\t\t\t; Camera start in texture px (= W/2); wraps modulo FD_W
""")
print(f"angles {NANG}, rows {R0}..95 ({rows}), pixels {rows*256}, footprint R={maxR}, texture W={W} (={W//32} stamps)")
print(f"tables {len(angles)/1e6:.2f} MB ({per_angle/1024:.1f} KB/angle), textures 2x3 x {W*H/1e6:.2f} MB -> data total {(len(angles)+2*tex3size)/1e6:.2f} MB")
