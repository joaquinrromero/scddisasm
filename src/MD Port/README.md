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

## Zonas de tiempo: un motor + despacho por zona
El motor se ensambla **una sola vez**. Lo que cambia entre zonas se elige al arrancar el nivel:
- `LoadZoneVars` (`Level/Zone Dispatch.asm`) copia a RAM (`zoneVars`, `$FFFFF012`, hueco sin uso) el bloque de 27
  punteros de la zona actual desde `ZoneTable`. Índice: 0 pasado, 1 presente, 2 buen futuro, 3 mal futuro
  (`timeZone` con el bit 7 enmascarado; en el futuro `goodFuture` decide, igual que el IPX original).
- Los datos se leen por esos punteros (`zPLCLists`, `zLevelLayouts`, `zObjectIndex`, `zPaletteTable`...) y las
  6 rutinas de zona (scroll, dibujo de nivel, palette cycle...) por trampolines `ZoneXxx`
  (`move.l zXxx,-(sp)` + `rts`, conservan todos los registros).
- `levelChunksPtr` (`$FFFFF00E`) apunta a los chunks de la zona. **Alineación:** el motor arma direcciones de
  chunk pisando solo el byte/word bajo de la base, así que cada bloque de chunks va alineado a `$10000`
  (el generador pone el `ALIGN`). Quitarlo exige reescribir las 4 búsquedas para que sumen la base.
- Presente = los archivos originales. Pasado, Buen y Mal Futuro = `MD Port/Zones/<Zona>/`, **generados** por
  `tools/make_zone_files.py "<Zona>"` desde los originales de cada zona (y `tools/make_zone_table.py` arma
  `Zone Table.asm`). El generador: prefija con `Zona_` toda etiqueta propia de la zona (las que difieren de Presente
  y las exclusivas de la zona), no repite los ~417 assets idénticos, expande los includes anidados específicos de
  zona, no repite los 3 includes de motor (`Palette Cycle Script`, `Scroll Flag Set`, `Block Draw`; deja un `jmp`
  para conservar el fall-through) y convierte los `bsr/bra/lea(pc)` hacia el motor en `jsr/jmp/lea` absolutos
  (el código de zona queda lejos del motor).
- Trampas que ya aparecieron (cubiertas en el generador; revisar si se agregan zonas): includes de motor ejecutados
  *en línea*, tablas `dc.w A-B` (todo lo de la resta viaja junto a la tabla), datos leídos de corrido tras otro
  bloque (`LevelPaletteID` tras `LevelDataIndex`: lista `FORCE`; el generador avisa los casos sospechosos) y nombres
  autogenerados por dirección (`byte_20c446`) que coinciden entre zonas.
- Para sumar una zona/acto: generar sus archivos, incluir `Zones/<Zona>.asm` en `Main.asm`, sumarla a `ZONES` en
  `make_zone_table.py` y a `LoadZoneVars`.
- Dev: `MDZONE=past|goodfuture|badfuture ./build_md.sh` arranca en esa zona.
- Los builds ISO originales (R11x, Wacky Workbench) **ya no compilan**: el motor compartido lee las variables de zona.

## Rondas de otros actos (tools/rounds, en curso)
`tools/rounds/extract_round.py R12A` toma una ronda generada por `mmd2md` y extrae solo lo propio de su zona/acto como un
delta reubicable contra el motor de PPZ Acto 1: parte de los 27 punteros de `zoneVars`, calcula la clausura de lo que
alcanzan, prefija con `R12A_`, convierte punteros literales `$2xxxxx` en `etiqueta+offset` (mapa de direcciones sacado del
listado de la propia ronda), recupera etiquetas internas de rutinas que el decompilador fusionó, pone trampolines `jmp` en
las tablas `dc.w A-B` que apuntan al motor y copia a la zona las tablas del motor que se indexan con `(pc,dN)`.
`make_zone_table.py` arma la tabla (indice = acto*4 + zona de tiempo) y `LoadZoneVars` la indexa con `act`.
**Estado:** R12A (PPZ Acto 2 Presente) ensambla sin errores pero el nivel termina en `ErrorTrap` (ver ROM `_act2_WIP`).
Causa sin identificar; primera pista: la tabla de objetos del Acto 2 (IDs 23 y 60 -> `R12A_Obj17_...`, `R12A_Obj3C_...`).
Arranque de desarrollo: `MDACT=1 ./build_md.sh`. R12B/C/D y R13C/D no se extrajeron todavia.

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

## Herramientas
`tools/emu/` (arnés headless sobre Genesis Plus GX): `python3 tools/emu/run.py check ROM --frames 3000 --pc 60 --stack`
y `run.py compare REF NEW`. Una sola llamada da escrituras a ROM, estado de RAM, PC muestreado, stack simbolizado,
hashes de pantalla y un PNG compuesto. Requiere el core con `tools/emu/romw_hook.patch`.
`tools/find_rom_writes.py` (correr desde `src/`): `python3 ../tools/find_rom_writes.py "Special Stage"`.
Encuentra datos `dc/ds` que el código escribe (directo o vía `lea`+puntero). No entiende `if def(MDPORT)`,
así que `debugSpeed` sigue apareciendo aunque ya esté movido a RAM (falso positivo). Para lo que el
análisis estático no ve (direcciones calculadas), usar el log de escrituras a ROM de un emulador.

## Pendiente
- Otras zonas/actos (R12 en adelante), sonido, pantalla de título.
- Driver de sonido (Sonic 1) y mapeo de `SCMD_*`.
- Pantalla de título, resto de zonas.
