#!/bin/sh
# Build the Mega Drive port (Linux/macOS, needs Wine because asm68k.exe is a Win32 tool)
#   usage: ./build_md.sh                 -> out/sonic_cd_md.bin
#          MDWARPTEST=1 ./build_md.sh    -> same, but boots straight into the time warp screen (dev)
set -e
cd "$(dirname "$0")"
export WINEDEBUG=-all
WINE=${WINE:-$(command -v wine || echo /usr/lib/wine/wine)}
mkdir -p out/misc
cd src

asm() {  # asm <source> <output> <listing> [extra asm68k flags...]
    src=$1; out=$2; lst=$3; shift 3
    "$WINE" ../bin/asm68k.exe /p /o ae-,l.,ow+ /e REGION=1 /e DEMO=0 /e MDPORT=1 "$@" \
        "$src", "$out", , "$lst" | tee /tmp/md_build.log
    grep -qE "(^|[^0-9])0 error\(s\)" /tmp/md_build.log || { echo "BUILD FAILED: $src"; exit 1; }
}

# The ROM itself (level + time warp game mode, one assembly)
EXTRA=""
[ -n "$MDWARPTEST" ] && EXTRA="/e MDWARPTEST=1"
asm "MD Port\\Main.asm" "..\\out\\sonic_cd_md.bin" "MD Port\\Main.lst" $EXTRA
cd ..
python3 - <<'PY'
import struct
p = "out/sonic_cd_md.bin"
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
