# wc — Verificación diferencial de la reconstrucción de /usr/bin/wc (SRXRE)

Reconstrucción semántica de `/usr/bin/wc` — GNU coreutils 9.10 — para LC_ALL=C y es_AR.utf8,
con verificación diferencial contra el binario real, **más de 40.000 casos sellados, 0 divergencias**.

Binario objetivo: sha256 `81d614595c717be908fce809713702efd35ce5a56f5ab7cbc497d1a61eb1a38f` · BuildID `07a56ef5bcfd9b400c0dc0441530607b3c7d65f8` · 61.448 B · stripped · dinámico.

## Alcance — qué está verificado y qué NO

**Verificado (2 locales, corpus sellado)**
| Modo        | Corpus              | LC_ALL=C | es_AR.utf8 |
|-------------|---------------------|----------|------------|
| default (L W B), 2nd gen #1 | seed 20261114 (4.899) | 0 | 0 |
| default (L W B), 2nd gen #2 | seed 20261115 (4.914) | 0 | 0 |
| default + flags {default,-c,-l,-w} combinaciones (8 sets × 1.484 contenidos) | seed 20261116 (11.872) | 0 | — |
| -L (max-line) + 16 conjuntos de flags | seed 20261117 (13.072) | 0 | — |
| bytes altos + NBSP | seed 20261118 (1.184) | 0 | 0 |
| bytes altos + UTF-8 (multibyte-aware) | seed 20261120 (1.184) | 0 | 0 |
| -m (chars) en UTF-8 (multibyte, 1.526 casos) | seed 20261121 | — | 0 (verify_m) |
| -L (anchura real Unicode: combinantes=0, East-Asian Wide/Fullwidth=2) | seed 20261123 (1.523) | — | 0 (verify_L) |
| -m observado == bytes en LC_ALL=C | 4 corpora verificados + 20261119 (4.926/4.926) | 0 | — |
| Byte-clasificación LC_ALL=C 0–255 | probe nativo | 0 | — |

La tabla de anchura Unicode (`wc/src/wc_width_table_gen.h`, generada) fue verificada 1:1 contra
`wcwidth(3)` de glibc para **todos los codepoints asignados (292.531), mismatch=0**; válida para
esa glibc; ver SEAL_WC.txt hito 10.

**Verificado por auditoría byte-para-byte** (word separators en LC_ALL=C: {09 0a 0b 0c 0d 20 a0};
-L width en C: exactamente {0x20–0x7e} con TAB al siguiente múltiplo de 8 y reset en {0a 0c 0d}).

**NO verificado:**
- Port 1:1 del desensamblado (observacional, no instrucción-por-instrucción).
- UTF-8 inválido (secuencias re-sincronizadas): nativo y modelo divergen — fuera de alcance (documentado, hito 10).
- Otros locales (más allá de C y es_AR.utf8) sin verificar.
- PUERTA cond. 3 y verificación por terceros: NOT_EXECUTED (pendientes; ver issue #1 del repo).

## Cómo reproducir (3 pasos, cualquiera)

```sh
shasum -a 256 -c wc/SHA256SUMS   # o equivalente sha256sum -c
gcc -std=c11 -O2 -o verify_wc wc/src/wc_count.c wc/harness/verify_wc.c
./verify_wc wc/corpus/cases_seed20261114.txt wc/corpus/matrix_native_wc.txt C
# esperado: total=4899 mismatches=0
```

Prueba el resto de corpora (cada corpus con la locale de su oráculo):
```sh
./verify_wc wc/corpus/cases_highutf8_seed20261120.txt wc/corpus/matrix_highutf8_C.txt C
./verify_wc wc/corpus/cases_highutf8_seed20261120.txt wc/corpus/matrix_highutf8.txt utf8
./verify_wc wc/corpus/cases_wcL_seed20261117.txt wc/corpus/matrix_native_wcL.txt C
./verify_wc wc/corpus/cases_high_seed20261118.txt wc/corpus/matrix_high_LC_ALL=C.txt C
./verify_wc wc/corpus/cases_high_seed20261118.txt wc/corpus/matrix_high_esAR.txt utf8
./verify_wc wc/corpus/cases_seed20261115.txt wc/corpus/matrix_native_wc_20261115.txt C
./verify_wc wc/corpus/cases_wcflags_seed20261116.txt wc/corpus/matrix_native_wcflags.txt C
```

Verificadores específicos de los hitos multibyte (misma fuente, comparación por codepoints):
```sh
gcc -std=c11 -O2 -o verify_m wc/src/wc_count.c wc/harness/verify_m.c
./verify_m wc/corpus/cases_m_utf8_seed20261121.txt wc/corpus/matrix_native_m_utf8.txt utf8
# esperado: total=1526 mismatches=0
gcc -std=c11 -O2 -o verify_L wc/src/wc_count.c wc/harness/verify_L.c
./verify_L wc/corpus/cases_L_utf8_seed20261123.txt wc/corpus/matrix_native_L_utf8.txt utf8
# esperado: total=1523 mismatches=0
```

El modo explícito (C|utf8) fuerza la ruta de clasificación — usa el que coincide con la generación
del oráculo. Sin modo, el verificador detecta desde LC_ALL/LANG, que puede diferir del entorno en
que se generó el oráculo (en ese caso los resultados "divergen" sin haber un defecto real).

Segundo aparato de verificación (built independientemente): un harness por milestone hereda la misma
semántica; la prueba más sólida es reconstruir el proceso con tu propia herramienta.

## Límite superior admisible

- La reconstrucción es **CONTRATO SEMÁNTICO**, no una implementación de producción.
- No incluye `--files0-from`, orden condicionado por locale, reparaciones multibyte, ni combinaciones
  flags × multibyte exhaustivas fuera del dominio sellado.
- **Esta publicación no afirma PASS ni hecho completo para wc** — sólo evidencia diferencial sellada
  bajo estos corpus y estos locales.

## Sello criptográfico

Hashes de corpus y matrices en `wc/SHA256SUMS`; proceso de sellado reproducible (instrucciones en SEAL_WC.txt).
