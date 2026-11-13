#!/bin/sh
# verify.sh — rxre-cleanroom v1.3.0 — verificación única, fail-closed.
# Reproduce: integridad del paquete, identidad nativa del oráculo, build +
# diferencial (2 generaciones + challenge corpus), invariancia de locale,
# i18n black-box y los 11 corpora de wc. Tolerancia cero: un mismatch aborta.
set -e
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

echo "== 1/8  paquete: integridad SHA256SUMS (raíz + wc/) =="
( cd "$ROOT" && sha256sum -c SHA256SUMS )
( cd "$ROOT" && sha256sum -c wc/SHA256SUMS )

echo "== 2/8  identidad nativa del oráculo (fail-closed) =="
LS_ID=54e936d37decdad9ecaf189b1de347605a0a99037ec87bd17679b6cbde871a0c
WC_ID=81d614595c717be908fce809713702efd35ce5a56f5ab7cbc497d1a61eb1a38f
a_ls=$(sha256sum /usr/bin/ls | cut -d' ' -f1)
a_wc=$(sha256sum /usr/bin/wc | cut -d' ' -f1)
if [ "$a_ls" != "$LS_ID" ]; then
  echo "FAIL: /usr/bin/ls ($a_ls) no coincide con el sello $LS_ID — aborta"; exit 3
fi
if [ "$a_wc" != "$WC_ID" ]; then
  echo "FAIL: /usr/bin/wc ($a_wc) no coincide con el sello $WC_ID — aborta"; exit 4
fi
echo "native identity OK: /usr/bin/ls=$a_ls /usr/bin/wc=$a_wc"

echo "== 3/8  build de la reconstrucción + harness =="
gcc -std=c11 -Wall -Wextra -Werror -O2 -o "$TMP/verify2" "$ROOT/harness/verify2.c" "$ROOT/src/filenvercmp.c"
echo "build OK (gcc -O2, -Wall -Wextra -Werror)"

echo "== 4/8  filenvercmp: 2 generaciones selladas + challenge corpus =="
"$TMP/verify2" "$ROOT/oracle/cases_seed20261112.txt" "$ROOT/oracle/matrix_native.txt"
"$TMP/verify2" "$ROOT/oracle/cases_seed20261113.txt" "$ROOT/oracle/matrix_native_20261113.txt"
"$TMP/verify2" "$ROOT/oracle/cases_challenge_seed20261126.txt" "$ROOT/oracle/matrix_challenge.txt"
"$TMP/verify2" "$ROOT/oracle/cases_challenge_b_seed20261126.txt" "$ROOT/oracle/matrix_challenge_b.txt"

echo "== 5/8  locale invariance (C ≡ es_AR.utf8, ambas generaciones, byte-equal) =="
cmp "$ROOT/oracle/matrix_native.txt" "$ROOT/oracle/matrix_native_es_AR_utf8.txt"
cmp "$ROOT/oracle/matrix_native_20261113.txt" "$ROOT/oracle/matrix_native_es_AR_utf8_20261113.txt"
echo "locale invariance OK (gen 1, gen 2 byte-equal)"

echo "== 6/8  filenvercmp i18n black-box (200 nombres UTF-8 vs oráculo/ls -v) =="
gcc -std=c11 -Wall -Wextra -Werror -pedantic -O2 -I "$ROOT/src" -o "$TMP/sort_names" \
  "$ROOT/filenvercmp_i18n/sort_names.c" "$ROOT/src/filenvercmp.c"
"$TMP/sort_names" "$ROOT/filenvercmp_i18n/names_i18n.txt" > "$TMP/i18n.out"
cmp "$TMP/i18n.out" "$ROOT/filenvercmp_i18n/oracle_lsAv_i18n.txt"
cmp "$TMP/i18n.out" "$ROOT/filenvercmp_i18n/reconstructed_sorted_i18n.txt"
echo "i18n black-box OK (byte-identical)"

echo "== 7/8  wc: build + 11 corpora (LC_ALL=C y es_AR.utf8) =="
gcc -std=c11 -Wall -Wextra -Werror -O2 -o "$TMP/verify_wc" "$ROOT/wc/src/wc_count.c" "$ROOT/wc/harness/verify_wc.c"
gcc -std=c11 -Wall -Wextra -Werror -O2 -o "$TMP/verify_m" "$ROOT/wc/src/wc_count.c" "$ROOT/wc/harness/verify_m.c"
gcc -std=c11 -Wall -Wextra -Werror -O2 -o "$TMP/verify_L" "$ROOT/wc/src/wc_count.c" "$ROOT/wc/harness/verify_L.c"
gcc -std=c11 -Wall -Wextra -Werror -O2 -o "$TMP/verify_flags" "$ROOT/wc/src/wc_count.c" "$ROOT/wc/harness/verify_flags.c"
LC_ALL=C        "$TMP/verify_wc"    "$ROOT/wc/corpus/cases_seed20261114.txt"        "$ROOT/wc/corpus/matrix_native_wc.txt"        C
LC_ALL=C        "$TMP/verify_wc"    "$ROOT/wc/corpus/cases_seed20261115.txt"        "$ROOT/wc/corpus/matrix_native_wc_20261115.txt" C
LC_ALL=C        "$TMP/verify_flags" "$ROOT/wc/corpus/cases_wcflags_seed20261116.txt" "$ROOT/wc/corpus/matrix_native_wcflags.txt"   C
LC_ALL=C        "$TMP/verify_flags" "$ROOT/wc/corpus/cases_wcL_seed20261117.txt"     "$ROOT/wc/corpus/matrix_native_wcL.txt"      C
LC_ALL=C        "$TMP/verify_wc"    "$ROOT/wc/corpus/cases_high_seed20261118.txt"    "$ROOT/wc/corpus/matrix_high_LC_ALL=C.txt"   C
LC_ALL=C        "$TMP/verify_wc"    "$ROOT/wc/corpus/cases_highutf8_seed20261120.txt" "$ROOT/wc/corpus/matrix_highutf8_C.txt"      C
LC_ALL=es_AR.utf8 "$TMP/verify_wc"    "$ROOT/wc/corpus/cases_high_seed20261118.txt"    "$ROOT/wc/corpus/matrix_high_esAR.txt"      utf8
LC_ALL=es_AR.utf8 "$TMP/verify_wc"    "$ROOT/wc/corpus/cases_highutf8_seed20261120.txt" "$ROOT/wc/corpus/matrix_highutf8.txt"       utf8
LC_ALL=es_AR.utf8 "$TMP/verify_m"     "$ROOT/wc/corpus/cases_m_utf8_seed20261121.txt"  "$ROOT/wc/corpus/matrix_native_m_utf8.txt"  utf8
LC_ALL=es_AR.utf8 "$TMP/verify_L"     "$ROOT/wc/corpus/cases_L_utf8_seed20261123.txt"  "$ROOT/wc/corpus/matrix_native_L_utf8.txt"  utf8
LC_ALL=es_AR.utf8 "$TMP/verify_flags" "$ROOT/wc/corpus/cases_flags_utf8_seed20261125.txt" "$ROOT/wc/corpus/matrix_flags_utf8.txt"   utf8

echo "== 8/8  alcance honesto =="
echo "verificación propia del autor, un único host/UID; verificación de terceros: NOT_EXECUTED (issue #1)"
echo "corpora --files0-from sellados (3.000 sintéticos, hitos 15-17): registros en wc/SEAL_WC.txt;"
echo "las 3.000+2.200 fichas sintéticas no se redistribuyen, así que esa rama NO es reejecutable desde este clon."
echo ""
echo "VERIFY: all steps passed"
