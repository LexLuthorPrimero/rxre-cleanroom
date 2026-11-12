# RXRE clean-room — reconstrucción verificable de `filenvercmp` / `filevercmp`

Reconstrucción semántica, escrita a mano a partir del desensamblado de `/usr/bin/ls`
(GNU coreutils 9.10), de la función `filenvercmp` y de sus subfunciones
`verrevcmp` y `file_prefixlen`, junto con un protocolo de verificación diferencial
**de tolerancia cero** diseñado para ser ejecutado por cualquiera, sin confiar
en el autor.

- Binario objetivo: `/usr/bin/ls` — sha256 `54e936d37decdad9ecaf189b1de347605a0a99037ec87bd17679b6cbde871a0c` · BuildID `ae6605eeca6cc2f19d18fdd53a521e501df3456d` · 153 400 B · ELF64 PIE stripped.
- Funciones: `filenvercmp` @ vaddr `0x4fa0`, `verrevcmp` @ `0x4b60`, `file_prefixlen` @ `0x4a80`.
- Corpus y oráculo: **propios y sintéticos** (nada de GNU coreutils); el oráculo se generó llamando al propio binario nativo mediante `mmap` (no se leyó ni derivó código fuente GPL).

## Qué demuestra (con verificación propia del autor)

- El corpus sellado de 20261112 (34.145 pares) y el de 20261113 (34.145 pares) coinciden **al 100 %** entre la reconstrucción `src/filenvercmp.c` y el oráculo nativo (`oracle/matrix_native*.txt`).
- Verificación acotada adicional del autor: 3 toolchains (gcc -O0/-O2, clang -O2) × 2 generaciones = 6/6, cero divergencias; 650.000 pares aleatorios de diagnóstico, cero divergencias; caja negra `LC_ALL=C ls -A -v` sobre 250 nombres creados en tmpfs, secuencia idéntica.

## Qué NO demuestra (explícito, sin ocultar)

- **Verificación por terceros autónomos: NO EJECUTADA.** Toda la evidencia anterior es del mismo host, mismo UID, misma persona y mismo modelo (el autor y su agente). No se reclama independencia de host, de modelo ni de observador.
- No se declara `PASS` del "motor RXRE" ni de ninguna capacidad general: esto es **una función** de un binario concreto (`/usr/bin/ls`, `sort=version`).
- La reconstrucción es un artefacto experimental; **no está pensada para producción** y no reemplaza a GNU coreutils.
- Defectos conocidos superados por este método: una versión anterior (2026-11-12, previa) fallaba en 791/34.145 casos del mismo corpus por modelar de forma empírica en vez de transcribir el desensamblado. El método (corpus sellado → oráculo nativo → diferencial a cero tolerancia) fue el que lo reveló.
- GNU coreutils es GPLv3: este paquete **no** redistribuye su código; `/usr/bin/ls` de tu propio sistema se usa solo como oráculo en tiempo de ejecución (mmap, solo lectura).

## Cómo reproducir (5 pasos, cualquiera)

Requisitos: `gcc` o `clang`, `python3`, un `/usr/bin/ls` compatible (misma versión si quieres comparar el oráculo; el diferencial contra matrices selladas no necesita `ls`).

```sh
# 1) comprueba el paquete
sha256sum -c SHA256SUMS

# 2) compila la reconstrucción + harness parametrizado (rutas por argumento, sin elementos hardcoded)
gcc -std=c11 -Wall -Wextra -pedantic -Werror -O2 -o verify2 src/filenvercmp.c harness/verify2.c

# 3) diferencial vs oráculos sellados
./verify2 oracle/cases_seed20261112.txt oracle/matrix_native.txt
./verify2 oracle/cases_seed20261113.txt oracle/matrix_native_20261113.txt
#  esperado: total=34145 mismatches=0  (x2)

# 4) (opcional) regenerar el oráculo con tu propio /usr/bin/ls
#    (ver PROTOCOL.md; requiere gcc para matrix_gen si lo construyes)

# 5) reporta: crea un issue con (a) tu distro/versión de ls, (b) hashes verificados, (c) salida del paso 3.
```

## Veredicto para lectores externos

La única prueba legítima de "reconstrucción con cero divergencias verificada por terceros"
es que **tú** ejecutes los pasos 2–3 en tu máquina y lo reportes. Hasta entonces, este
paquete es una afirmación verificable del autor — no un hecho externo.

## Licencia

Código y documentos propios: ver `LICENSE`. Corpus y matrices: datos sintéticos del autor.
`/usr/bin/ls` no se incluye; es prerrequisito local del usuario.
