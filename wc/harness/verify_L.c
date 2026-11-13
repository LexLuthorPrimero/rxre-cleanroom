/* verify_L — RXRE cleanroom — verificador para wc -L multibyte (ancho real Unicode).
 * Uso: verify_L <cases-file> <matrix-file> [C|utf8]
 *   utf8 (recomendado): fuerza la ruta de clasificación UTF-8.
 * Corpus: "<content-escapado>" por línea. Matrix: max-line (anchura) por línea.
 * Exit 0 si 0 divergencias, 1 en otro caso.
 */
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <limits.h>
typedef struct { unsigned long lines, words, bytes, max_line, chars; } wc_count;
wc_count wc_count_str(const unsigned char *, size_t);
static size_t unescape(const char *src, uint8_t out[8192]) {
    size_t o = 0;
    for (size_t i = 0; src[i]; ) {
        if (src[i] == '\\' && src[i+1] == 'x') {
            unsigned v = 0;
            for (int k = 0; k < 2; k++) { char c = src[i+2+k]; v <<= 4;
                if (c >= '0' && c <= '9') v |= (unsigned)(c - '0');
                else if (c >= 'a' && c <= 'f') v |= (unsigned)(c - 'a' + 10);
                else v |= (unsigned)(c - 'A' + 10); }
            out[o++] = (uint8_t)v; i += 4;
        } else out[o++] = (uint8_t)src[i++];
    }
    return o;
}
int main(int argc, char **argv) {
    if (argc < 3) { fprintf(stderr, "uso: %s <cases> <matrix> [C|utf8]\n", argv[0]); return 2; }
    if (argc >= 4) { if (!strcmp(argv[3], "C")) setenv("LC_ALL", "C", 1);
                     else if (!strcmp(argv[3], "utf8")) setenv("LC_ALL", "es_AR.utf8", 1); }
    FILE *cases = fopen(argv[1], "rb"), *expected = fopen(argv[2], "rb");
    if (!cases || !expected) return 2;
    char line[16384]; uint8_t a[8192]; char abuf[8192];
    size_t n = 0, mism = 0;
    while (fgets(line, sizeof line, cases)) {
        char *nl = strchr(line, '\n'); if (nl) *nl = '\0';
        size_t alen = unescape(line, a);
        memcpy(abuf, a, alen); abuf[alen] = '\0';
        wc_count r = wc_count_str((unsigned char *)abuf, alen);
        char exp[64];
        if (!fgets(exp, sizeof exp, expected)) { fprintf(stderr, "unexpected EOF after line %zu\n", n); return 2; }
        long e = strtol(exp, NULL, 10);
        if ((long)r.max_line != e) { mism++;
            if (mism <= 20) fprintf(stderr, "MISMATCH line=%zu recon_max_line=%lu native_max_line=%ld\n", n, r.max_line, e); }
        n++;
    }
    fclose(cases); fclose(expected);
    fprintf(stderr, "total=%zu mismatches=%zu\n", n, mism);
    return mism ? 1 : 0;
}
