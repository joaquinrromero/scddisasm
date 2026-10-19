#!/bin/sh
# Build the Mode 7 floor demo ROM (needs Python 3 + numpy, and Wine for asm68k.exe)
#   usage: ./build_floor_demo.sh           -> out/floor_demo_md.bin
# Variables: NANG (yaw angles, default 64), R0 (first baked row, default 25)
set -e
cd "$(dirname "$0")"
export WINEDEBUG=-all
WINE=${WINE:-$(command -v wine || echo /usr/lib/wine/wine)}
python3 tools/floor/bake_floor_demo.py
mkdir -p out
cd src
"$WINE" ../bin/asm68k.exe /p /o ae-,l.,ow+ "MD Port\\Floor Demo.asm", "..\\out\\floor_demo_md.bin", , "MD Port\\Floor Demo.lst" | tee /tmp/floor_demo_build.log
grep -qE "(^|[^0-9])0 error\(s\)" /tmp/floor_demo_build.log || { echo "BUILD FAILED"; exit 1; }
cd ..
python3 - <<'PY'
import struct
p = "out/floor_demo_md.bin"
d = bytearray(open(p, "rb").read())
if len(d) % 2: d.append(0)
assert len(d) <= 4 * 1024 * 1024, "ROM is larger than 4 MB (needs bankswitching)"
d[0x1A4:0x1A8] = struct.pack(">L", len(d) - 1)
s = 0
for i in range(0x200, len(d), 2):
    s = (s + (d[i] << 8 | d[i + 1])) & 0xFFFF
d[0x18E:0x190] = struct.pack(">H", s)
open(p, "wb").write(d)
print("ROM %s: %d bytes (%.2f MB of 4), checksum $%04X" % (p, len(d), len(d) / 1048576, s))
PY
