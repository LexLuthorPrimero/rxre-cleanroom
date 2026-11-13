# rxre-cleanroom

Reconstrucción y **verificación diferencial a tolerancia cero** de dos piezas de
GNU coreutils 9.10 contra sus binarios stripped reales:

- **`filenvercmp`** — el comparador *version-aware* dentro de `/usr/bin/ls` con el
  algoritmo de ordenamiento por versión (`sort=version`) de GNU: `filenvercmp` @ `0x4fa0`,
  `verrevcmp` @ `0x4b60`, `file_prefixlen` @ `0x4a80`
- **`wc`** — el contador de líneas/palabras/bytes/ancho de `/usr/bin/wc` en ambos locales
  (`LC_ALL=C` y `es_AR.utf8`), incluidos `-m` multibyte y `-L` con tabla de ancho real
  (verificada 1:1 contra `wcwidth(3)`)

Cada milestone viene con su **corpus sellado criptográficamente**, **oráculo nativo**,
**reconstrucción**, **harness verificador** y **sello** (`SEAL_WC.txt` / `SEAL` logs).

**Estado (sin adornos):** verificado por el autor en un único host/UID/modelo (IA asistida).
La verificación **de terceros/ciega NO se ha ejecutado**. La única puerta que importa para el
ciclo R3 son lecturas independientes — abre o comenta
[el issue #1](https://github.com/LexLuthorPrimero/rxre-cleanroom/issues/1).

## Verifica en un comando (v1.3.0)

```sh
git clone https://github.com/LexLuthorPrimero/rxre-cleanroom
cd rxre-cleanroom
./verify.sh
```

Fail-closed, 8 etapas: integridad `SHA256SUMS` (raíz + `wc/`), identidad nativa
(`/usr/bin/ls`/`/usr/bin/wc` por SHA-256; cualquier otra coincidencia aborta), build,
2 generaciones (34.145×2) + challenge corpus (3.100 + 3.241), invariancia de locale
(C ≡ es_AR.utf8, gen 1+2 byte-equal), i18n black-box (200 nombres UTF-8), y los 11
corpora de wc. Cola esperada: `VERIFY: all steps passed`. Requisitos: Linux x86_64,
gcc, `sha256sum`, GNU coreutils con los hashes sellados.

Manual (lo de siempre, auditable paso a paso):

```sh
sha256sum -c SHA256SUMS
gcc -std=c11 -O2 -o verify2 harness/verify2.c src/filenvercmp.c
./verify2 oracle/cases_seed20261112.txt oracle/matrix_native.txt
# total=34145 mismatches=0
```

**Novedad v1.3.0**: `verify.sh` único; matrices de locale selladas (`oracle/matrix_native_es_AR_utf8{,_20261113}.txt`); textos coherentes con el paquete hermano. Verificación de terceros sigue **NOT_EXECUTED** (issue #1). Los corpora `--files0-from` permanecen sellados en `wc/SEAL_WC.txt` pero las 5.200 fichas sintéticas no se redistribuyen: esa rama no es reejecutable desde un clon fresco (documentado en el paso 8/8 de `verify.sh`).

## Contenido

| Milestone | Corpus sellado | Divergencias | Locales |
|---|---|---|---|
| filenvercmp gen 1 | 34.145 (20261112) | 0 | C |
| filenvercmp gen 2 | 34.145 (20261113) | 0 | C |
| wc default (L W B) ×2 | 9.813 (20261114/15) | 0 | C |
| wc flags (8 sets × contenidos) | 11.872 (20261116) | 0 | C |
| wc `-L` + 16 conjuntos de flags | 13.072 (20261117) | 0 | C |
| wc bytes altos/NBSP (2 × 1.184) | 2.368 (20261118) | 0 | C + es_AR.utf8 |
| wc bytes altos/UTF-8 | 2.368 (20261120) | 0 | C + es_AR.utf8 |
| wc **`-m`** multibyte | 1.526 (20261121) | 0 | es_AR.utf8 |
| wc **`-L`** tabla real Unicode | 1.523 (20261123) | 0 | es_AR.utf8 |
| wc **flags × multibyte** (14 sets) | 18.592 (20261125) | 0 | es_AR.utf8 |
| filenvercmp **locale-invariance** byte-idéntico | 2×34.145 | byte-equal | C **y** es_AR.utf8 |
| filenvercmp **i18n challenge** (adversarial exterior) | 3.100 + 141 | 0 | es_AR.utf8 |
| wc **`--files0-from`** default/`-l`/`-m`/folds | 3.000 files (20261127) | 0 | C + es_AR.utf8 |
| wc **adversarial fuzz** `--files0-from` | 2.200 files (20261128) | 0 | C + es_AR.utf8 |

Total general: **170.000+** case-checks sellados, 0 divergencias (bit-audit 256/256 en LC_ALL=C aparte).

Verificación fresca (clone nuevo, sin estado previo) — todos los runs dan `0 divergencias`:
`wc/harness/verify_{wc,m,L,flags}.c`.

## Qué NO es

- No es port 1:1 del desensamblado; es **contrato semántico** verificado diferenciando.
- No redistribuye código de GNU coreutils (oráculo runtime = mmap read-only).
- No afirma PASS, hecho completo ni verificación de terceros; ver `PROTOCOL.md` y `wc/SEAL_WC.txt`.
- Licencia MIT (obra propia; copyright `/usr/bin/ls` y `/usr/bin/wc` sigue siendo de la FSF).

## Proyectos relacionados

- Motor RXRE (área de investigación, MIT): https://github.com/LexLuthorPrimero/rxre-engine — release [v1.3.0](https://github.com/LexLuthorPrimero/rxre-engine/releases/tag/v1.3.0) (zip hash-verificado; incluye [`reviewer-kit/`](https://github.com/LexLuthorPrimero/rxre-engine/tree/main/reviewer-kit) para revisión ciega)
- Protocolo seal-before-reveal y roadmap: `PROTOCOL.md`, `OUTREACH.md` (cómo reportar en issue #1)
