/* verify_flags.c — RXRE cleanroom — verificador público flags × multibyte UTF-8: verifica flags × multibyte (es_AR.utf8) de la reconstrucción.
 * Uso: verify_flags_u8 <cases> <matrix> [C|utf8]   (utf8 fuerza la ruta multibyte)
 * Corpus: "<flags> \t <contenido hexa-escapado>". Matrix: salida GNU normalizada (tokens).
 */
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <limits.h>
typedef struct { unsigned long lines, words, bytes, max_line, chars; } wc_count;
wc_count wc_count_str(const unsigned char *, size_t);
size_t wc_format_flags(char *, size_t, wc_count, unsigned);
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
static unsigned parse_flags(const char *f) {
    unsigned bits = 0;
    for (const char *p = f; *p; p++) {
        if (*p == '-' && p[1]) { p++;
            while (*p && *p != ' ' && *p != '\t') {
                if (*p == 'l') bits |= 1;
                else if (*p == 'w') bits |= 2;
                else if (*p == 'c') bits |= 4;
                else if (*p == 'L') bits |= 8;
                else if (*p == 'm') bits |= 16;
                p++;
            } p--;
        }
    }
    return bits;
}
static int extract_ints(const char *src, unsigned long out[]) {
    int n = 0; const char *p = src;
    while (*p && n < 8) {
        if (*p >= '0' && *p <= '9') { unsigned long v = 0;
            while (*p >= '0' && *p <= '9') { v = v * 10 + (unsigned long)(*p - '0'); p++; }
            out[n++] = v;
        } else p++;
    }
    return n;
}
int main(int argc, char **argv) {
    if (argc < 3) { fprintf(stderr, "uso: %s <cases> <matrix> [C|utf8]\n", argv[0]); return 2; }
    if (argc >= 4) { if (!strcmp(argv[3], "C")) setenv("LC_ALL", "C", 1);
                     else if (!strcmp(argv[3], "utf8")) setenv("LC_ALL", "es_AR.utf8", 1); }
    FILE *cases = fopen(argv[1], "rb"), *expected = fopen(argv[2], "rb");
    if (!cases || !expected) return 2;
    char line[16384], exp[256], got[256]; uint8_t a[8192];
    size_t n = 0, mism = 0;
    while (fgets(line, sizeof line, cases)) {
        char *nl = strchr(line, '\n'); if (nl) *nl = '\0';
        char *tab = strchr(line, '\t');
        if (!tab) return 2;
        *tab = '\0'; char *flags = line; char *content = tab + 1;
        size_t alen = unescape(content, a);
        wc_count r = wc_count_str((unsigned char *)a, alen);
        unsigned bits = parse_flags(flags);
        wc_format_flags(got, sizeof got, r, bits);
        if (!fgets(exp, sizeof exp, expected)) return 2;
        unsigned long gi[8], ei[8];
        int gn = extract_ints(got, gi), en = extract_ints(exp, ei);
        int bad = (gn != en);
        for (int k = 0; !bad && k < en; k++) bad = gi[k] != ei[k];
        if (bad) { mism++; if (mism <= 20)
            fprintf(stderr, "MISMATCH line=%zu flags='%s' recon='%s' native='%s'\n", n, flags, got, exp); }
        n++;
    }
    fclose(cases); fclose(expected);
    fprintf(stderr, "total=%zu mismatches=%zu\n", n, mism);
    return mism ? 1 : 0;
}
