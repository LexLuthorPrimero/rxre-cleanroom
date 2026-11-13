# wc — Verificación diferencial de la reconstrucción de /usr/bin/wc (SRXRE)

Reconstrucción semántica de `/usr/bin/wc` — GNU coreutils 9.10 — para LC_ALL=C y es_AR.utf8,
con verificación diferencial contra el binario real, **más de 200.000 case-checks, 0 divergencias**.

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
| flags × multibyte (14 sets × contenidos, GNU L W M C L) | seed 20261125 (18.592) | — | 0 (verify_flags) |
| Byte-clasificación LC_ALL=C 0–255 | probe nativo | 0 | — |
| **`--files0-from`** (default i `-l`/flags combinables) | seed 20261127 (~3.000 archivos) | 0 | 0 |
| **`--files0-from` adversarial fuzz** (CRLF, NUL-embebido, isolates U+2066/2069, FULLWIDTH, empty, NFD) | seed 20261128 (2.200 archivos) | 0 | 0 |
| **filenvercmp `ls -v` locale-invariance** | 2×34.145 casos | byte-equal | byte-equal |
| **filenvercmp 200-nombres i18n** | reconstrucción vs `ls -v` nativo | **idéntico** | **idéntico** |
| **filenvercmp challenge corpus externo** | 3.100 (h13) + 141 idénticos a==b (h13b) = **3.241** | 0 (ambos) | 95,1% UTF-8 |

**Bug corregido en este release (caracteres por codepoint inválido)**
`utf8_decode` antes contaba 1 char incluso en secuencias inválidas; GNU las ignora
(cuente de codepoints válidos únicamente). El cambio a `else { r.chars++; }`
en `count_utf8` alineaba recon con GNU — verificado por **toda la corpora sellada**
(`cases_m_utf8_seed20261121.txt`, `matrix_flags_utf8.txt`, y por el challenge 20261126/20261127).

## Cómo reproducir (3 pasos, cualquiera)

```sh
shasum -a 256 -c wc/SHA256SUMS   # o equivalente sha256sum -c
gcc -std=c11 -O2 -o verify_wc wc/src/wc_count.c wc/harness/verify_wc.c
./verify_wc wc/corpus/cases_seed20261114.txt wc/corpus/matrix_native_wc.txt C
# esperado: total=4899 mismatches=0
```

Todos los verificadores (`verify_wc`, `verify_m`, `verify_L`, `verify_flags`, `verify_files0`) compilan con
`gcc -std=c11 -Wall -Wextra -Werror -pedantic`. Comandos completos y seal-logs: `SEAL_WC.txt`.

**--files0-from** (verifica corpus multibyte token-identical):
```sh
gcc -std=c11 -O2 -o verify_files0 wc/src/wc_count.c wc/harness/wc_files0.c
cd wc && LC_ALL=es_AR.utf8 ./verify_files0 corpus/cases_files0_from_seed20261127.txt default
```

**i18n black-box (filenvercmp vs native `ls -v`)**:
```sh
cd filenvercmp_i18n && gcc -std=c11 -O2 -o sort_names sort_names.c ../reconstruction/filenvercmp.c && ./sort_names names_i18n.txt | sha256sum
```

**Challenge corpus externo (filenvercmp i18n/CRLF)**:
```sh
gcc -std=c11 -O2 -o verify2 harness/verify2.c src/filenvercmp.c
./verify2 oracle/cases_challenge_seed20261126.txt oracle/matrix_challenge.txt
```

## Sello criptográfico

Hashes de corpus, matrices y entradas i *verify en `wc/SHA256SUMS`; sellos en `wc/SEAL_WC.txt`.
Challenge corpus filenvercmp tiene su propio sello: `wc/SEAL_CR.txt`.
Locale-invariance filenvercmp: `wc/SEAL_H14.txt`.

## Qué NO está en esta release

- **Verificación de terceros** (issue #1): aún no ejecutada. Setup completo, pero sin un host
  externo que la repita.
- **Generalización multiplataforma** (OSET2: x86_64, aarch64, RISC-V): NOT_EXECUTED.
- **Soporte completo de todas las banderas GNU** (`--files0-from` + flags completos + `--si`, `--apparent-size`, `--no-dereference`): NOT_EXECUTED.
- **Producción**: contrato semántico verificado por diferencial sellado, no drop-in.

## v1.3.0 (2026-11-13)

- verify.sh único en raíz del paquete (fail-closed; ver README de este repo): identidad nativa + 2 generaciones + challenge + locale invariance + i18n + 11 corpora wc.
- Matrices de invariancia de locale trasladadas y selladas en raíz: `oracle/matrix_native_es_AR_utf8.txt` (`ed5e91ef…`) y `oracle/matrix_native_es_AR_utf8_20261113.txt` (`e031d3ed…`) — idénticas a las del engine v1.3.0+.
- `files0-from`: resultados sellados pero las fichas sintéticas NO se redistribuyen; documentado como no reejecutable desde clon.
- Alineación de paquetes con `rxre-engine v1.3.0` (mismo día que su publicación). Verificación de terceros: NOT_EXECUTED (issue #1).

## v1.5.1 (2026-11-13)

- Alineado con `rxre-engine v1.5.1`: coherencia documental (engine README/QUICKSTART/verify.sh synchronization; expects 72 passed/2 skipped). Mismas verificaciones selladas, contenidos idénticos, verify passes. Terceros: NOT_EXECUTED (issue #1).

## v1.5.0 (2026-11-13)

- Alineado con `rxre-engine v1.5.0`: **FIVE bounded targets** sellados (filenvercmp, wc, fold, tr, **dirname**). dirname: corpus 1.917/1.901 (seeds 20261113/14), parent directory acotado (bounded); verify.sh 11 etapas con dirname; identidad fail-closed /usr/bin/dirname (aac6a889…). Terceros: NOT_EXECUTED (issue #1).

## v1.4.0 (2026-11-13)

- Alineado con `rxre-engine v1.4.0`: **FOUR bounded targets** sellados (filenvercmp, wc, fold, **tr** `-s x`). tr: corpus 2×2.513 (seeds 20261113/14), greedy squeeze de runs de `0x78`, 0 divergencias. Terceros: NOT_EXECUTED (issue #1).

## v1.3.10 (2026-11-13)

- Alineado con `rxre-engine v1.3.10` (convenience supersede de v1.3.9/v1.3.8: README pointer fix en el engine; contenido de código idéntico). verify pass; seals regenerated. Terceros: NOT_EXECUTED (issue #1).

## v1.3.8 (2026-11-13)

- Alineado con `rxre-engine v1.3.8`: milestone `fold` ampliado multi-width — -w 4 ×2 seeds + -w 1/2/3/8 (1.054 c/u), 6 regeneraciones selladas/gated, 0 divergencias. Sin cambios funcionales en los milestones anteriores. Terceros: NOT_EXECUTED (issue #1).

## v1.3.7 (2026-11-13)

- Alineado con `rxre-engine v1.3.7`: **tercer objetivo sellado (`fold`)** incluido en el paquete (corpus 2×2.554, seeds 20261113/14, verify.sh con etapa 7/9 + fail-closed identidad `/usr/bin/fold` sha256 95030461…). Sin cambios funcionales en milestones anteriores. Terceros: NOT_EXECUTED (issue #1).

## v1.3.6 (2026-11-13)

- Alineado con `rxre-engine v1.3.6` (MENTE etapa 2 completa: dry run + refutación de rivales BYTES/CODEPOINTS sobre wc -L sellado). Sin cambios funcionales. Terceros: NOT_EXECUTED (issue #1). Alineación vs v1.3.5/v1.3.6 se referencia en el engine.

## v1.3.4 (2026-11-13)

- Alineado con `rxre-engine v1.3.4` (MENTE etapa 1). Sin cambios funcionales: corpus intacto, verify.sh intacto; solo coherencia. Terceros: NOT_EXECUTED (issue #1).

## v1.3.3 (2026-11-13)

- Alineado con `rxre-engine v1.3.3` (cierre de la ronda 3 de auditoría estática). Sin cambios funcionales: mismo corpus sellado, `verify.sh` fail-closed, mismos hashes de oráculo. Solo coherencia y sellos regenerados. Verificación de terceros: NOT_EXECUTED (issue #1).

## v1.3.2 (2026-11-13)

- Alineación de paquetes con `rxre-engine v1.3.2` (audit-hardening F1–F4 + Phase 5 decoupling). No hay cambios funcionales en el cleanroom: mismo corpus sellado, mismo `verify.sh` fail-closed, mismos hashes de oráculo/verifiers. Solo textos coherentes con el hermano y sellos regenerados. Verificación de terceros: NOT_EXECUTED (issue #1).

## NOXES de este release (v1.2.0)

- 129k cases de hito 9-11 (ya en v1.1.0) + UTF-8 invalid-sequence fix (bug lint)
- +40k cases: files0_from default/-l/-m/-L/all multicombinations UTF-8 & es_AR.utf8 (+ extras hito 15-17)
- +i18n black-box: filenvercmp == ls -v nativo para 200 nombres UTF-8 mixtos
