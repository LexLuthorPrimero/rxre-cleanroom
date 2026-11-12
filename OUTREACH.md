# Kit para verificador humano ciego (2026-11-12)

Objetivo: que una persona **ajena al autor** ejecute el protocolo y firme su resultado, sin
contacto con el autor antes del dictamen.

## Requisitos
- Linux x86_64 con un `/usr/bin/ls` de GNU coreutils 9.10 (o compatible) para regenerar el oráculo; para el diferencial contra matrices selladas basta cualquier máquina con `gcc`/`clang` + esta carpeta.
- Sin contacto previo con el expediente; recibir SOLO este paquete.

## Pasos
1. `sha256sum -c SHA256SUMS` — debe pasar en todos los archivos.
2. `gcc -std=c11 -Wall -Wextra -pedantic -Werror -O2 -o verify2 src/filenvercmp.c harness/verify2.c`
3. `./verify2 oracle/cases_seed20261112.txt oracle/matrix_native.txt`
   `./verify2 oracle/cases_seed20261113.txt oracle/matrix_native_20261113.txt`
4. (Opcional, oráculo propio) construir un generador de oráculo equivalente a `matrix_gen`
   (mmap de `/usr/bin/ls` en `0x4fa0`, lectura escapeada, un entero por línea) y re-generar `oracle/matrix_native*` con SEED=20261112/20261113; verificar mismos hashes o documentar diferencias (p. ej., versión distinta de coreutils → otra matriz; eso ya no valida la MISMA hipótesis, documentarlo).
5. Reportar (issue en el repo público): versión de SO/distro/coreutils, salida de los pasos 1–4, tu dictamen.

## Plantilla de informe
```
Máquina/distro:
Binario /usr/bin/ls: sha256= BuildID= versión=
Paso 1 (sha256sum -c): OK/FAIL (listar)
Paso 3: total=… mismatches=… (2 líneas)
Paso 4 (si aplica): hashes obtenidos vs sellados: iguales/distintos + entorno
Dictamen: VERIFICADO_POR_TERCERO / NO_REPRODUCE / INSUFFICIENT (sin evidencia)
Notas (honestas, con incertidumbres explícitas):
```

## Qué significa cada dictamen
- `VERIFICADO_POR_TERCERO`: el tercero reprodujo cero divergencias en ambas generaciones selladas.
- `NO_REPRODUCE`: el tercero halló divergencias → evidencia de defecto; se corrige y se documenta (el protocolo premia el fallo, no lo oculta).
- `INSUFFICIENT`: no se pudo ejecutar el protocolo (entorno insuficiente) → sin afirmación; no penaliza al método como tal.
