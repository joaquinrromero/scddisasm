# mmd2md

Sonic CD round `.MMD` (`R<round><act><A-D>__.MMD`) → split disassembly → standalone Mega Drive ROM, in one command.

```
pip install capstone                       # (smoke.py also needs: pip install unicorn)
python tools/mmd2md/mmd2md.py tools/R31A__.MMD            # one round
python tools/mmd2md/mmd2md.py tools/*.MMD --jobs 4         # all 70 rounds
python tools/mmd2md/mmd2md.py tools/R41A__.MMD --no-md     # decompile + split only
python tools/mmd2md/smoke.py "out/md/R31A Collision Chaos Act 1 Present.bin" 300
```
Needs `bin/asm68k.exe` (wine on Linux/macOS). Output ROMs: `out/md/<id> <Zone> <Act> <Time>.bin`.

## What it does for each MMD
1. **Trace** (`mmdlib/trace.py`): recursive-descent M68K disassembly with capstone from the header vectors / stubs;
   jump tables, `bra` tables and pointer tables are followed; speculative traces of pointers found in code/data are
   accepted only when they look like real code.
2. **Name** (`mmdlib/refnames.py`): the Palmtree Panic Act 1 Present level is built from this repo and its symbols are
   transferred by matching windows of identical instructions, operand pairing and verbatim data blobs (~99 % correct
   when checked against the real symbols of R11B/R11D/R61A). RAM variables / object fields use `Level/_Definitions.inc`.
3. **Structure** (`mmdlib/levelstruct.py`): level data index, PLC lists, chunks, demo, collision, layouts, object
   layouts, palette table, the Sub-CPU command routine and every Gate Array access.
4. **Split + emit** (`mmdlib/emit.py`) → `src/Level/<Zone>/<Act> <Time>.asm` and
   `src/Level/<Zone>/Data/{Art,Level,Objects,Collision,Palette,Mappings,Animations,Misc}`. Nemesis art is
   recognised by decompressing it (exact size), identical files are stored once per zone, collision maps shared with
   `Level/_Data` are reused. Hand-written sources are never overwritten (`... (Generated).asm`).
5. **Round trip**: assembles with asm68k and compares with the MMD. Instructions asm68k can not reproduce
   (e.g. `$0(aN)`) are emitted as `dc.b`. The build stops unless the result is **byte-identical**.
6. **Mega Drive build** (`mmdlib/mdport.py`): `MD Port/Main (<id>).asm` is derived from `MD Port/Main.asm`
   (zone/act, time zone, good future flag). Under `if def(MDPORT)` the level keeps every address:
   the Sub-CPU command routine is replaced by `MD Port/Sound Stub.asm` (NOP padded to the original size),
   Gate Array accesses become NOPs, and data the level writes to inside its own (now ROM) area is moved to RAM
   (`RomVar_xxxxxx`, found by scanning for absolute-long writes).

## Limits
* Writes to ROM through pointers / PC-relative addresses can not be found statically: run `smoke.py` and watch
  "ROM writes".
* Only the Palmtree Panic build is used as naming reference, so zone-specific objects keep `Obj<nn>_<addr>` /
  `loc_` / `sub_` names until renamed.
* Sound is the stub (phase 2: Sonic 1 driver). Only the level being built is in the ROM; time warp restarts it.
* Round 8 act 2 (R82A) has a different layout header: its layouts stay as plain data segments.
