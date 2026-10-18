# Collision Chaos Act 1 (Present) - R31A__.MMD

Desensamblado de R31A__.MMD (generado por `tools/r31a/`, ver `build_check.sh`).

- `Act 1 Present.asm`: codigo + tablas. Con asm68k reproduce el MMD byte a byte (sin `/e MDPORT`).
- `Data/`: arte Nemesis (`Art_*.nem`), `Blocks`, `Tiles`, `Chunks`, `Demo`, `Collision`, `Layout (FG|BG|FG2|FG3...)`,
  `Objects (Act 1).bin`, mapas/DPLC de Sonic y `Padding`. Las tablas de colision comunes se toman de `Level/_Data/`.
- ~80% del codigo es el mismo motor que R11A (se identifico comparando contra el build de R11A del repo, de ahi los nombres).
  Lo propio de la zona (objetos, eventos, scroll, ciclo de paleta) conserva nombres `sub_/loc_/ObjNN_` hasta que se renombre.

## Build Mega Drive
`./build_md_ccz.sh` -> `out/sonic_cd_ccz_md.bin` (usa `MD Port/Main (CCZ).asm`, mismo header/init que el port de PP).
El nivel queda en su direccion original ($200000, cartucho > 2 MB) para no tocar ningun puntero absoluto:
- V-INT: el `bset #0,GATEARRAY` se reemplaza por 4 NOP (mismo tamano).
- `FadeOutMusic/SubCPUCmd`: se reemplaza por `MD Port/Sound Stub.asm`, rellenado con NOP hasta el tamano original.
Cualquier cambio bajo `if def(MDPORT)` debe conservar los tamanos o la alineacion de `LevelChunks` ($10000) se rompe.

## Pendiente
- Sonido (driver de Sonic 1), pasado/futuros (R31B/C/D no estan), renombrar objetos propios de CCZ.
- Reubicar el nivel junto al resto (hoy ocupa $200000-$23FFFF con ~2 MB de relleno) cuando haya tabla de zonas.
