#!/bin/sh
# Build the Mega Drive special stage port (objects only; needs Wine for asm68k.exe)
#   usage: ./build_md_ss.sh            -> out/sonic_cd_ss_md.bin
set -e
cd "$(dirname "$0")"
export WINEDEBUG=-all
WINE=${WINE:-$(command -v wine || echo /usr/lib/wine/wine)}
mkdir -p out
cd src
"$WINE" ../bin/asm68k.exe /p /o ae-,l.,ow+ /e REGION=1 \
    "MD Port\\Special Stage.asm", "..\\out\\sonic_cd_ss_md.bin", , "MD Port\\Special Stage.lst" | tee /tmp/md_ss_build.log
grep -qE "(^|[^0-9])0 error\(s\)" /tmp/md_ss_build.log || { echo "BUILD FAILED"; exit 1; }
cd ..
python3 - <<'PY'
import struct
p = "out/sonic_cd_ss_md.bin"
d = bytearray(open(p, "rb").read())
assert len(d) % 2 == 0
d[0x1A4:0x1A8] = struct.pack(">L", len(d) - 1)           # ROM end
s = 0
for i in range(0x200, len(d), 2):                        # checksum: sum of words after the header
    s = (s + (d[i] << 8 | d[i + 1])) & 0xFFFF
d[0x18E:0x190] = struct.pack(">H", s)
open(p, "wb").write(d)
print("ROM %s: %d bytes, checksum $%04X" % (p, len(d), s))
PY
