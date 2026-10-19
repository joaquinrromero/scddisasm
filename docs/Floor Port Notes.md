# Suelo de la fase especial en Mega Drive: arquitectura, mapa de RAM y mediciones

Notas sobre la rama `md-special-stage-port` después del arreglo del solape de RAM. Se separan lo **medido** (con el emulador 68000 de pruebas y el modelo en Python) de lo **deducido**.

## 1. Resumen

- El solape de RAM era real y se resolvió con un **mapa de RAM único** (`src/MD Port/RAM Map.inc`) que comprueba en la build que ninguna región pisa a otra.
- El suelo se dibuja ahora por **bandas** (4 bandas de 8 columnas de tile) con **dos buffers de banda** en RAM, y el V-INT copia cada banda por DMA al buffer de VRAM **oculto**; el intercambio con el visible se hace al completar la imagen.
- Descubrimiento clave de rendimiento: si el sampler corre antes del primer `VSync`, el bucle principal baja a **12 fps de lógica**, aunque la CPU esté libre la mitad del tiempo. Se resolvió dibujando el suelo **dentro de la espera de `VSync`**, en tajadas de 2 filas.
- Resultado medido (stage 1, 30 s de juego): **lógica a 20,0 fps (3,00 VBlanks por frame, como el original), imágenes de suelo a 5,8 por segundo, 0 VBlanks perdidos, 0 escrituras a ROM.**
- El sampler produce los mismos bytes que el modelo en Python en 9 poses de 7 stages (0 bytes distintos).

| Configuración | Muestras por imagen | Imágenes de suelo por s | Lógica | VBlanks perdidos |
|---|---|---|---|---|
| Antes: `SampleFloor` entero cada 2 frames (h2v2) | 6.144 | ~2,5 | ~4,9 fps | n/a |
| Una banda por frame de lógica, dentro de `SSFrame` (h4v2) | 3.072 | ~3 | 12 fps | no medido |
| **Tajadas en `VSync`, 4 bandas (h4v2, por defecto)** | 3.072 | **5,8** | **20,0 fps** | 0 |
| Tajadas en `VSync`, 8 bandas (h4v2) | 3.072 | 5,0 | 20,0 fps | 0 |
| Tajadas en `VSync`, 4 bandas, h2v2 (`FLOORHDIV=2`) | 6.144 | 3,3 | 20,0 fps | 0 |

## 2. Cómo funciona el suelo original

El chip gráfico del Mega CD recorre el mapa de stamps guiado por una *trace table*:

- 96 filas, 4 words con signo por fila: `Xs, Ys, Dx, Dy`. `Xs/Ys` en 1/8 de píxel del mapa de 4096x4096 px; `Dx/Dy` es el paso **por dot** en 1/2048 px.
- Posición del dot `i`: `X = (Xs*256 + i*Dx) >> 11`. Sin repetición: fuera de 0..4095 px la salida es transparente.
- Mapa de stamps: 128x128 words por filas (bits 0-10 = número x4, 13-14 rotación, 15 flip). Stamps de 32x32 a 4 bpp.
- Salida: 256x96 dots a 4 bpp en columnas de tiles (**384 B por columna**, 32 columnas).
- El pitch es constante (`$80`), por eso `Trace Table.asm` puede calcular cada fila con 5 `muls` y sin divisiones.

## 3. Archivos de la rama relacionados

| Archivo | Papel |
|---|---|
| `src/MD Port/Special Stage.asm` | Wrapper: vectores, arranque, `SSNextStage`, includes |
| `src/MD Port/RAM Map.inc` / `RAM Check.inc` | Mapa de RAM y sus comprobaciones (nuevos) |
| `src/MD Port/Trace Table.asm` | `GenGfxTraceTblMD`: trace table sin divisiones |
| `src/MD Port/Floor Sampler.asm` | Renderizador por tajadas/bandas, DMA de bandas, carga de datos |
| `src/MD Port/Floor Data/Stage N/` | `stamp_remap.bin` y `stamps_4bpp.bin` por stage (`stamps_1bpp.bin` no se usa) |
| `src/Special Stage/Main.asm` | `VSync` con tajadas, estados del V-INT, variables del suelo |

## 4. El solape de RAM

Con `stageImage` (12 KB) en RAM, el bloque de variables del display llegó a `$4B00` y se montó sobre los globales y `SSRWDATA`; además `TRACETBLMD` (`$FFFFE000-E2FF`) caía sobre 512 de los 768 B del `sonicArtBuf`, que se reescribe cada frame (de ahí los tiles corruptos de Sonic). **Causa raíz:** las direcciones de cada región estaban escritas a mano y nada avisaba al crecer una.

El buffer completo no entra aunque se ajusten reservas: 36.032 B de regiones contra 32.512 B disponibles, 3.520 B de más (5.568 B con el mínimo de pila de 2 KB).

### Mapa actual (`FLOORBANDS=4`, 2 buffers de banda)

| Región | Direcciones | Reservado | Real | Contenido |
|---|---|---|---|---|
| GA | `$FFFF8000-803F` | $40 | $40 | Bloque "gate array" (flags/registros de comunicación, RAM normal) |
| SUBVARS | `$FFFF8040-A53F` | $2500 | $2462 | Variables y objetos de la lógica (Sub.asm, `VARSLEN`) |
| SUBBUF | `$FFFFA540-AB3F` | $600 | $600 | Sprites y arte de Sonic entregados al display (`_Common.inc`) |
| TRACETBL | `$FFFFAB40-AE3F` | $300 | $300 | Trace table del suelo, 96 filas x 8 B (`TRACETBLMD`) |
| FLOORVARS | `$FFFFAE40-AE7F` | $40 | $10 | Variables del sampler (punteros, banda, fila, buffers, flags) |
| IMGBAND | `$FFFFAE80-C67F` | $1800 | $1800 | 2 buffers de banda del suelo (`stageImage`), 3.072 B cada uno con 4 bandas |
| MAINVARS2 | `$FFFFC680-E27F` | $1C00 | $1B04 | Variables del programa de display (Main.asm, `MainVarsStart..MainVarsEnd`) |
| MAINVARS | `$FFFFE280-F47F` | $1200 | $1100 | Globales estilo IPX (Main CPU Variables.inc, `MAINVARSSZ`) |
| RWDATA | `$FFFFF480-F4BF` | $40 | $35 | Datos escribibles que vivían dentro de la imagen del Main CPU |
| (libre / pila) | `$FFFFF4C0-$FFFFFEFF` | $A40 (2624 B) | pico medido 166 B | La pila crece hacia abajo desde `$FFFFFF00`; mínimo exigido `$800` |
| PERSIST | `$FFFFFF00-$FFFFFFFF` | $100 | 3 B | Magia `$5353` + ID de stage; sobrevive a los reinicios |

- Cada región se coloca justo después de la anterior con un tamaño **reservado**. `RAM Check.inc` (al final del ensamblado) comprueba que el tamaño real cabe; si no, el ensamblador **se detiene con un mensaje**. También falla si `FLOORBANDS` no divide las 32 columnas, o si no queda el mínimo de pila.
- El margen de pila es de 2.624 B y el pico medido es de **166 B** (6.300 frames, 8 stages con A+Start).
- `FLOORBANDS=8` (buffers de 1.536 B) deja 5.696 B de margen y una imagen de suelo cada 0,2 s; `FLOORBANDS=2` no entra.

## 5. Cómo se dibuja y se copia el suelo

1. `LoadFloorData` apunta a los datos del stage, pone `floorBand=0`, `floorRow=0` y deja visible el buffer 1 de VRAM (en blanco) mientras se construye el 2.
2. El bucle de espera de `VSync` llama a `SampleFloorSlice`, que guarda todos los registros y llama a `FloorWork` con `FLOORSLICEROWS` (2) filas. Cada llamada continúa donde quedó la anterior (`floorRow`).
3. Al empezar una imagen (banda 0, fila 0) se genera la trace table una vez; las 4 bandas comparten esa cámara.
4. Al terminar una banda se marca `floorReady[buffer] = banda+1` y se cambia al otro buffer RAM. Si ese buffer aún espera su DMA, el sampler no hace nada hasta que el V-INT lo libere.
5. En **cada** V-INT de copia (`VInt_CopyStage1_1/1_2/2_1/2_2/Done`) `CopyFloorBand` envía por DMA la banda lista más antigua al buffer **oculto** de VRAM. Al llegar la última banda, el oculto pasa a visible (`ShowFloorBuf` lo muestra con `ShowStageBuf1/2`, que solo cambian el scroll horizontal del plano A).

Condiciones de carrera revisadas: el productor solo escribe `floorReady` después de terminar de escribir la banda y el consumidor lo borra **antes** de lanzar el DMA, que detiene la CPU; por eso el sampler nunca escribe un buffer que se está copiando. `floorShowSel/floorHidSel` solo los toca el V-INT.

## 6. Verificación (reproducible)

Herramientas en `floor-tools.zip`:

- `verify_bands.py`: llama al sampler real en el emulador 68000, y compara cada banda con el modelo en Python **alimentado con la trace table que generó el propio 68K**. Resultado: 9 poses (stages 1, 2, 4, 5, 6, 7, 8), **0 bytes distintos** con 4 bandas h4v2, con 8 bandas h4v2 y con 4 bandas h2v2.
- Coste medido por banda (h4v2, 4 bandas): 238-243 k ciclos, 275-281 k la primera (incluye ~38 k de trace table). Una imagen entera: ~1,0 M ciclos.
- `gamerate.py`: ritmo de lógica, imágenes de suelo y VBlanks perdidos en régimen estable.
- Captura en emulador: suelo, Sonic sin corrupción, HUD, fondo con ciclo de paleta.

## 7. Notas de diseño y riesgos

- `adda.l d5,a6` suma un longword cuyo byte alto trae restos de los words intercambiados. Es inofensivo porque el 68000 ignora los bits 24-31 de la dirección.
- La cámara del suelo puede ir hasta ~12 VBlanks por detrás de los objetos (una imagen completa). No se aprecia salvo con giros rápidos.
- La CPU queda ocupada casi al 100 % (el suelo usa el tiempo libre). Añadir trabajo a la lógica reduce la tasa de imágenes de suelo, no la de lógica.
- Durante pausa y resultados el sampler sigue dibujando hasta llenar los dos buffers y luego espera.
- Si se vuelve a usar `FLOORHDIV=2`, el suelo baja a 3,3 imágenes por segundo.

## 8. Animación de stamps (ventiladores y peligros)

`AnimateStamps` escribe celdas del mapa en RAM, pero el sampler lee el remap estático de ROM: esas celdas no se animan en el suelo. Variantes `(id, rotación/flip)` por stage en el mapa:

| Stage | Stamps | Variantes | `stamps_4bpp` |
|---|---|---|---|
| 1 | 94 | 224 | 112 KB |
| 2 | 110 | 212 | 106 KB |
| 4 | 118 | 332 | 166 KB |
| 5 | 111 | 247 | 123 KB |
| 6 | 94 | 216 | 108 KB |
| 7 | 108 | 328 | 164 KB |
| 8 | 94 | 222 | 111 KB |

Un mapa de **un byte** por celda no sirve en general (stages 4 y 7 pasan de 255). Opciones: (a) un único mapa de variantes en RAM (words) que lean la colisión y el sampler; (b) lista corta de celdas animadas que el sampler consulte; (c) dejar el suelo sin animar.

## 9. Pendiente y ideas

- Stage 3 sin datos (usa otros nombres de archivo y dos juegos de stamps).
- Orden de rotación/flip de stamps: asumido (flip, luego rotación horaria); coherente pero no contrastado con hardware.
- Mejora de velocidad posible: usar `stamps_1bpp.bin` (sin selección de nibble) ahorraría ~35 ciclos por muestra (estimado) a costa de ~0,9 MB de ROM; no se hizo para respetar el presupuesto de ROM.
- Las tajadas de 2 filas retrasan como mucho unos ~5 k ciclos el regreso del bucle principal tras cada V-INT; si hiciera falta se pueden bajar a 1 fila (`FLOORSLICEROWS`).

## 10. Cómo reproducir

Harness Musashi (`mdsim.c`) con las opciones:

- `mdsim rom.bin N ram=vol.bin`: N frames con V-INT, escrituras a ROM, pila máxima.
- `ssframe=DIR idle=A-B count=DIR`: ciclos de `SSFrame`, tiempo en `VSync` y contadores de ejecución.
- `callfloor=... poke=...`: llama al sampler con RAM preparada y vuelca la imagen y la trace table.
- `f:mascara`: mando simulado (`C0` = A+Start).

## 11. Bug del ID de stage (corregido)

El commit `0a4d659` cambió el ID por defecto a 1 (y `SSNextStage` a ciclo 1..8) para que `LoadFloorData` no rechazara el 0. Pero **todo el código original usa IDs de 0 a 7**: las tablas `StageMaps` y `LoadStageData`, los bits de las Time Stones (`bset d0,timeStonesSub`), `TimeStonePalettes`, los `cmpi.b #1-1,specStageID`, etc. Con el 1 en el arranque, la colisión, el fondo y la paleta salían del stage siguiente mientras el suelo seguía usando los datos del stage 1.

Medido en la ROM de la rama antes del arreglo: `specStageID = 1` y el mapa de colisión cargado en RAM coincide con el del **stage 2** en un 99,9 % (y 42 % con el del stage 1). Con A+Start los IDs 2, 3, ... cargaban los stages 3, 4, ...

Arreglo: el ID es **0-based en todo el port**. `LoadFloorData` indexa su tabla directamente con el ID (el 0 es válido), el arranque ya no fuerza ningún valor (la RAM recién borrada es el stage 1) y `SSNextStage` vuelve a `andi.b #7`. Verificado para los 8 IDs: el ID, el mapa de colisión (99,8-100 % contra los datos de su stage) y los punteros del suelo corresponden siempre al mismo stage; el stage 3 no tiene datos de suelo en el repo y queda sin suelo.

## 12. Dónde se va la CPU (perfil de 2.700 frames)

| Parte | % de la CPU |
|---|---|
| Suelo (bucle interno, preparación de filas, trace table, DMA de bandas) | 72,5 |
| Lógica del juego, objetos y proyección 3D de sprites | 15,4 |
| Fondo: scroll y ciclos de paleta | 3,1 |
| HUD (anillos, UFOs, tiempo) | 0,5 |
| V-INT | 0,5 |
| Espera en `VSync` | 0,4 |
| Resto (controles, copia de sprites...) | 5,4 |

El suelo ocupa todo el tiempo libre por diseño (se dibuja dentro de `VSync`), así que ese 72,5 % es "lo que se le deja", no un coste fijo. Lo importante: **optimizar el fondo y el HUD liberaría como mucho ~3,5 % de la CPU.** La lógica a 20 fps ya cuesta ~27 % de la CPU en total.

Limitaciones de la medición: el emulador de pruebas no modela las pausas de la CPU durante el DMA ni las esperas de bus. Una banda de 3 KB son ~9 k ciclos de pausa (estimado con el ancho de banda de DMA de H32 en VBlank, ~167 B por línea); deja un margen del 5-10 % en hardware real.

## 13. Qué resolución cabe (modelo de coste)

Presupuesto de suelo: 72 % de la CPU = ~5,5 M ciclos por segundo. Solo el coste de 310 ciclos por muestra está medido; los demás son estimaciones.

| Resolución | Muestras por imagen | 310 ciclos (medido) | 220 ciclos (estimado tras optimizar) | 120 ciclos (optimista) |
|---|---|---|---|---|
| h4v2 | 3.072 | 5,6 imágenes/s | 7,7 | 13 |
| h2v2 | 6.144 | 2,8 | 4,0 | 7,1 |
| h2v1 | 12.288 | 1,4 | 2,0 | 3,7 |
| 1:1 (93 filas x 256) | 23.808 | 0,7 | 1,0 | 1,9 |

Para un 1:1 a 10 imágenes/s harían falta ~23 ciclos por píxel; a 20 imágenes/s, ~11. Un `move.b d0,(a1)+` solo ya cuesta 8-12 ciclos.

Referencia pública: en el foro SpritesMind, gasega68k publicó demos de modo 7 por software con 256x96 de área y resolución vertical doblada (48 filas únicas) a 26-27 fps, con un mapa virtual plano de 256x256 a 8 bits en RAM externa de 64 KB y ROM de ~45 KB. Eso equivale a unos 24 ciclos por muestra (cálculo propio), posible porque la textura es un bitmap plano de un byte por píxel sin indirección de stamps ni comprobación de límites. No pude encontrar información sobre la técnica de MarkeyJester.

## 14. El proyecto de MarkeyJester ("Mega Drive Sonic CD Mode 7 Test", 18-oct-2016)

Lo que dice la descripción del video (palabras del autor, resumidas):

- Una versión de 2012 renderizaba a píxel doble con una imagen enorme y pixelada en ROM, y solo cabía un stage pequeño.
- La versión de 2016 renderiza el suelo a **píxeles individuales**, como el Mega CD original (3 líneas más que el original), y tarda **3-4 frames** en dibujar una imagen, "más o menos igual que el Mega CD".
- El stage es un **layout de supercedas de 20x20 píxeles**, lo que permite guardar stages enteros del juego en ROM y animar piezas individuales.
- La profundidad/perspectiva está calculada correctamente (la versión anterior era "una casualidad").
- Limitación: **no se puede estar dentro de una supercelda**, porque se le acabó la ROM; podía pasar de los 4 MB reservados y entrar en memoria que exigiría bankswitching, lo que quería evitar para que funcionara en emuladores.

Lo que eso implica con nuestros números (la descripción no detalla la técnica; esto es inferencia):

- 3-4 frames para ~23.800 píxeles son ~384-512 k ciclos, es decir **~16-21 ciclos por píxel con toda la CPU**. Con muestreo directo y stamps medimos 181 (bucle simple) a ~310 ciclos (el sampler actual), así que su técnica tiene que apoyarse en **precomputación en ROM**. Encaja con la ROM cerca de 4 MB y con la restricción de la supercelda: algo está tabulado por posición.
- Un bucle de 2 instrucciones por píxel (`move.w (a2)+,d0` + `move.b (a3,d0.w),(a1)+`) cuesta ~26 ciclos (cuenta de instrucciones, sin medir): es el orden de magnitud que necesita.

Lo que sabemos de nuestros datos y que sirve para decidir:

- La cámara original está en **píxeles enteros** (`oX`, `oY` son words en píxeles y se desplazan 3 bits). Por eso la trace table relativa a la cámara depende solo del yaw y de la altura Z: `X = cam*2048 + ((Xs_rel*256 + i*Dx) >> 11)`.
- Z vale `$160` y cambia durante los saltos (temporizador de 20 frames), así que hay varios valores de Z, no uno.
- El yaw tiene 512 valores. Guardar un offset por píxel para cada (yaw, Z) cuesta ~71 KB por combinación, o ~9 MB con 128 yaws: no cabe. La trace table ya es la forma comprimida; lo caro es el acceso al texel (indirección de stamps), no los offsets.
- Dibujar por tramos de texels repetidos ahorra poco: 83 % de los píxeles son tramos nuevos (72 % en las filas más cercanas), así que el tope es ~17-28 %.

## 15. Plan hacia píxeles individuales (propuesta)

1. **Medible y sin cambiar el formato** (cada paso verificado bit a bit contra el modelo): tabla de filas calculada una vez por imagen, `stamps_1bpp.bin` si la ROM lo permite, fila completa desenrollada en ROM, tramos de texels y muestreo adaptativo por fila (las filas lejanas son ruido). Objetivo: h4v2 a 8 imágenes/s o más, o h2v2 a 5 o más.
2. **Investigación de la precomputación**: cuántos yaws hacen falta de verdad (cuantizar 512 a 64-128 y mirar el error visible), qué hacer durante los saltos (volver al sampler lento o cuantizar Z), y cuánta ROM cuesta una representación plana de la parte jugable del mapa que evite la indirección de stamps.
3. **Prototipo del bucle más rápido posible** medido en el emulador, con objetivo <= 26 ciclos por píxel, para saber con datos si el presupuesto de ROM que se acepte alcanza para 3-4 frames por imagen.

Decisión pendiente: cuánta ROM total se acepta para el suelo.

## 16. Prueba con ROM cercana a 4 MB: microbenchmarks y cuentas

Dos estrategias "ROM por CPU" medidas en el emulador 68000 sobre 93 filas x 256 píxeles (23.808 px, 1 byte por píxel de salida, sin pausas de DMA ni de bus):

| Estrategia | Ciclos totales | Ciclos por píxel | VBlanks con toda la CPU | ROM por imagen precomputada |
|---|---|---|---|---|
| Tabla de offsets de 16 bits (`move.w (a2)+,d0` + `move.b (a3,d0.w),(a1)+`) | 635.610 | 26,7 | 5,0 | 47,6 KB |
| Código horneado (`move.b disp(a3),(a1)+`, una instrucción por píxel) | 380.952 | 16,0 | 2,98 | 95,2 KB |

El código horneado reproduce las cifras del autor ("3-4 frames", píxeles individuales). Eso apoya la inferencia de la sección 14: ROM cerca de 4 MB y la restricción de la supercelda salen de que cada imagen horneada pesa ~95 KB.

La contrapartida es combinatoria: **4 MB / 95 KB son unas 42 imágenes horneadas** (unas 84 con tablas de offsets). Una imagen horneada vale para un yaw, una altura Z y una disposición concreta de la textura. Para nuestro juego harían falta, por stage, 512 yaws (cuantizables a 32-64), varios Z (salto) y sobre todo una textura **plana** direccionable con un desplazamiento de 16 bits (`move.b d16(a3)` solo alcanza +-32 KB). Con el mapa de stamps (indirección) y la cámara libre en píxeles enteros, los desplazamientos relativos ya no son constantes. Hornear solo funciona si la textura es plana, y una textura plana de la parte jugable pesa 0,8-1,5 MB por stage solo en el stage 1 (más de 4 MB para todos).

Qué compra la ROM sin crecer combinatoriamente:

| Mejora | ROM extra | Efecto estimado |
|---|---|---|
| `stamps_1bpp.bin` en todos los stages (sin selección de nibble) | ~1,8-2 MB | -35 ciclos por muestra |
| Tabla remap con punteros premultiplicados | ~0,25 MB | -10 ciclos al cambiar de stamp |
| Trace table relativa por yaw (512 yaws, Z nominal) | ~0,4 MB | quita ~10 % de CPU (trace table y preparación de filas) |
| Total (ROM resultante ~3,3-3,6 MB) | | h4v2 a 7-8 imágenes/s, h2v2 a ~4 (estimado) |

Conclusión: con ROM cercana a 4 MB se puede comprar velocidad, pero no un 1:1 con cámara libre en todos los stages a 3-4 frames. Eso requeriría restringir la cámara (como el demo) o bajar a pocas decenas de ángulos.

## 17. Demo de suelo horneado a píxeles individuales (estilo MarkeyJester)

Es una ROM aparte (`build_floor_demo.sh` -> `out/floor_demo_md.bin`) que dibuja el suelo del stage 1 a **píxel individual (1:1)** desde tablas en ROM, con cámara libre dentro de una zona y yaw en pasos discretos.

### Diseño

- **Textura plana**: una región de 832x832 px del mapa del stage 1 (centrada en la posición inicial) como 1 byte por píxel, **dos copias** seguidas en ROM (`FloorTexHi` = color<<4 y `FloorTexLo` = color) para combinar dos texels en un byte 4bpp con un solo `or`.
- **Tablas por yaw (64 pasos de 5,6°)**: la cámara original está en píxeles enteros, así que el offset de cada píxel de pantalla respecto a la cámara depende solo del yaw (`X = cam + X_rel`, exacto). Cada tabla guarda, para las filas 25-95 en segmentos de 16 píxeles, un longword (offset del primer texel) y 15 words (offsets relativos al primero): 37,7 KB por ángulo. Mover la cámara es cargar un puntero.
- **Renderizado**: por cada par de píxeles `move.w (a2)+,d1` / `move.b (a3,d1.w),d0` / `move.w (a2)+,d1` / `or.b (a4,d1.w),d0` / `move.b d0,(a1)+`, escribiendo directamente el formato de tiles del VDP (columnas de tiles, `lea 380(a1),a1` entre columnas). Doble buffer en RAM (2 x 12 KB) y copia por DMA a VRAM en dos mitades en el V-INT.
- **Límites**: las filas 0-24 (el horizonte lejano, muy minificado) quedan transparentes; la cámara solo puede moverse en [278, 554] dentro de la textura (la huella visible llega a 276 px); el yaw tiene 64 pasos; la altura Z es fija (`$160`, sin saltos).

### Resultados medidos (emulador 68000, sin pausas de DMA ni de bus)

| | |
|---|---|
| ROM | 3.858.502 bytes (3,68 MiB de 4): tablas 2,47 MB + texturas 1,38 MB |
| Coste de una imagen | **529.460 ciclos, constante** (4,14 VBlanks con toda la CPU; ~29 ciclos por píxel) |
| Ritmo del bucle completo | 4,18 VBlanks por imagen = **14,4 imágenes/s** |
| Exactitud de la ROM | 0 bytes distintos contra el modelo horneado en 10 poses (cámara, yaw) |
| Exactitud contra el chip original | **0 de 18.176 píxeles distintos** entre el modelo horneado y el render de referencia del chip gráfico (filas 25-95), en las mismas 10 poses |
| Escrituras a ROM | 0 |

Controles: cruceta (en mednafen por defecto W/A/S/D): izquierda/derecha giran, arriba/abajo avanzan y retroceden.

### Por qué cabe en ~4 MB y qué le falta para ser el juego

- Cabe porque el coste por ángulo es fijo (37,7 KB) y la textura plana se reparte sin indirección de stamps; los 64 ángulos y la zona de 832x832 consumen casi todo el presupuesto, igual que en el demo original.
- Falta: una textura plana por cada stage (cada una de unos 1,4 MB con dos copias para una zona de este tamaño), saltos (Z variable), las filas lejanas del horizonte, integrar la cámara con la lógica de Sonic (la cámara "reformulada": yaw en pasos, zona acotada que sigue a Sonic), el fondo y el HUD, y la animación de stamps.
- Con 4 MB solo se puede hornear una zona por stage; para recorrer un stage entero la textura tendría que cambiar de zona (streaming de ROM o varias texturas con bankswitching).
