# Sonic CD -> Mega Drive port

ROM única para Mega Drive: Palmtree Panic Act 1 (Presente) + cutscene de time warp.
Sin sonido todavía (`Sound Stub.asm` descarta los comandos del Sub CPU).

## Compilar
`./build_md.sh` (necesita Wine para `asm68k.exe`) -> `out/sonic_cd_md.bin`.
`MDWARPTEST=1 ./build_md.sh` arranca directo en la cutscene (solo para desarrollo).

## Estructura
| Archivo | Qué es |
|---|---|
| `Main.asm` | Vectores, header, arranque de hardware (TMSS/Z80/VDP/RAM), bucle principal (reemplaza al IPX) |
| `Sound Stub.asm` | `SubCPUCmd` / `FadeOutMusic` sin efecto (fase 2: driver de Sonic 1) |
| `Time Warp/` | Cutscene portada como game mode (`TimeWarpCutscene`) |

## Cambios en archivos originales
Los 6 primeros van bajo `if def(MDPORT)` (el build ISO no cambia). Los de "Datos por zona" (`Block Draw`,
`Collision Floor`, `Main.asm`, `Sonic`, `Load Level Data` de PP y WWZ, `_Definitions.inc`) son incondicionales:
R11A/B/C/D y Wacky Workbench siguen compilando con 0 errores.
- `Level/Initialization.asm`: sin cabecera MMD.
- `Level/Main.asm`: sin `bset #0,GAIRQ2` en la V-INT.
- `Level/Sub CPU.asm`: usa `Sound Stub.asm`.
- `Level/Palmtree Panic/Act 1 Present.asm`: `_Definitions.inc` lo incluye `MD Port/Main.asm`.
- `Level/Palmtree Panic/Data (Act 1 Present).asm`: `ALIGN $10000` antes de `LevelChunks`
  (el código reemplaza solo el byte/word bajo de esa dirección).
- `Level/Debug Mode.asm`: `debugSpeed` ya no es un `dc.l` dentro del código.

## Datos por zona (en curso: hacia un solo motor + tabla)
- `levelChunksPtr` (RAM `$FFFFF00E`, en un hueco sin uso: no se movió ninguna otra dirección) reemplaza
  a las 9 referencias directas a `LevelChunks` (`Block Draw`, `Collision Floor`, objeto Sonic).
- `GetLevelDataIndex` (en `Load Level Data.asm`) elige el índice de datos con `timeZone` (bit 7 enmascarado)
  y lo usan `LoadLevelData` y el arranque del nivel (`Level/Main.asm`, que lee el PLC *antes* de `LoadLevelData`).
- `LevelDataIndexes` tiene 3 entradas (pasado/presente/futuro); hoy las tres apuntan a la zona que se ensambla.
- **Alineación:** el motor arma direcciones de chunk pisando solo el byte/word bajo de la base, así que cada
  bloque de chunks debe seguir alineado a `$10000` (ver `ALIGN` en `Data (Act 1 Present).asm`). El puntero en
  RAM quita el hardcodeo, no la alineación; para quitarla hay que reescribir las 4 búsquedas para que sumen la base.

## Regla importante: la ROM no se puede escribir
En el CD el nivel y la cutscene corrían desde RAM (Word RAM / Work RAM), así que podían
guardar variables *dentro del código* (`dc.w` + `addq` sobre ese label). En cartucho esas
escrituras se pierden en silencio. Se encontraron y movieron a RAM:
`PaletteCycle .Timer/.Index`, `vscrollBG`, `enableDisplay`, `curSonicTrailObj`, `debugSpeed`.
Si se porta código nuevo, buscar el patrón `label: dc.x` + escritura al label (o
`lea label(pc),aN` + escritura por `(aN)`).

## Mapa de RAM (Work RAM `$FF0000-$FFFFFF`)
| Rango | Uso | Dueño |
|---|---|---|
| `$FF0F00-$FF1FFF` | `MAINVARS` (timeZone, vidas, score, `ipxVSync`, `ipxVDPReg1`...) | compartido; **no se toca** al hacer el warp |
| `$FF2000-$FF4FFF` | `blockBuffer`, `unkBuffer2` | nivel (scratch) |
| `$FF5000-$FF7FFF` | sin uso | libre |
| `$FFFFA000-$FFFFAFFF` | layout, `nemBuffer` (`$FFFFAA00`) | nivel; **`NemDec` del nivel lo comparte la cutscene** |
| `$FFFFB000-$FFFFBC1B` | variables de la cutscene | time warp (antes: `$FFFF8000-$FFFFFBFF`) |
| `$FFFFC000-$FFFFC003` | `debugSpeed` | port |
| `$FFFFC800-$FFFFFBFF` | `sonicArtBuf`, objetos, sprites, paleta... | nivel |
| `$FFFFFD06` | `jmp` de la V-INT en RAM (`_LEVEL6`, slot heredado del BIOS) | port |
| `$FFFFFC00-$FFFFFFFF` | stack (~1 KB) | port |

La sección de la cutscene tiene un `fail` si llega a `$FFFFC000`.

## Código duplicado (candidato a unificar más adelante)
La cutscene conserva sus propias versiones (con prefijo `TW`) de rutinas que el nivel también
tiene, porque usan otras variables RAM / otro modelo de objetos y no eran idénticas:
`TWVInterrupt`, `TWVSync`, `TWStopZ80/TWStartZ80`, `TWReadController`, `TWRandom`,
`TWFadeTo/FromBlack/White`, `TWRunObjects`, `TWDrawObject`, `TWPaletteCycle`.
`NemDec*` y `EniDec` **no** se duplicaron (eran idénticos): se usa el del nivel (vía `jsr`,
porque queda fuera del alcance de `bsr.w`).

## Herramienta
`tools/find_rom_writes.py` (correr desde `src/`): `python3 ../tools/find_rom_writes.py "Special Stage"`.
Encuentra datos `dc/ds` que el código escribe (directo o vía `lea`+puntero). No entiende `if def(MDPORT)`,
así que `debugSpeed` sigue apareciendo aunque ya esté movido a RAM (falso positivo). Para lo que el
análisis estático no ve (direcciones calculadas), usar el log de escrituras a ROM de un emulador.

## Pendiente
- Time warp real: R11B/C/D (pasado / buen futuro / mal futuro) no están en la ROM; tras el warp
  se vuelve al presente (`MDMain`, `TODO phase 2`).
- Driver de sonido (Sonic 1) y mapeo de `SCMD_*`.
- Pantalla de título, resto de zonas.
