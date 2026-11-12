# Kit de difusión (listo para publicar; 5 minutos, 1 plataforma a la vez)

Regla de etiqueta: **una plataforma, un mensaje**. Sin spam; cada sitio tiene su estilo.
Publica desde tus propias cuentas; estos textos están escritos para lectores técnicos.

## Reddit — r/ReverseEngineering (o r/linux)
**Título:** Does this hand reconstruction of GNU coreutils `filenvercmp` (from disasm) reproduce exactly?
**Cuerpo:**
I reconstructed `filenvercmp`/`verrevcmp`/`file_prefixlen` from `/usr/bin/ls` (GNU coreutils 9.10, x86_64) by hand from disassembly — no source code. Two sealed corpora (seed 20261112 and 20261113; 34,145 pairs each), a native oracle via mmap of the binary, and a zero-tolerance differential: 0 divergences on my host.

I'd like a few people to try to reproduce (or refute) this. Package + 5 steps:
https://github.com/LexLuthorPrimero/rxre-cleanroom
If you'd rather just review: `INDEX.md` → build `verify2` → run against the sealed matrices. Report as an issue — even `NO_REPRODUCE` is valuable.

## Show HN (Hacker News)
**Título:** Show HN: A verifiable reconstruction of GNU coreutils `filenvercmp` — try to refute it
**Cuerpo:**
I wrote a from-disassembly reconstruction of `filenvercmp` from GNU coreutils 9.10 (`/usr/bin/ls`, BuildID ae6605ee…). The package ships the two sealed corpora, the native oracle matrices, and a zero-tolerance differential harness. Steps: `sha256sum -c SHA256SUMS`; `gcc -O2 -o verify2 src/filenvercmp.c harness/verify2.c`; `./verify2 oracle/cases_seed20261112.txt oracle/matrix_native.txt`; `./verify2 oracle/cases_seed20261113.txt oracle/matrix_native_20261113.txt`.
Expected: `total=34145 mismatches=0` (twice). If you see anything else, that's the interesting part — please report it.

Repo: https://github.com/LexLuthorPrimero/rxre-cleanroom

## Mastodon / Fediverse
1/ I reconstructed GNU coreutils `filenvercmp` from disasm (no source). Two sealed corpora × 34,145 cases; 0 divergences so far (my host only). Seeking blind reproductions.
2/ Try: `sha256sum -c`; `gcc -O2`; `./verify2 oracle/cases_seed20261112.txt oracle/matrix_native.txt` (+ 20261113 pair). Package: https://github.com/LexLuthorPrimero/rxre-cleanroom

## Qué NO hacer
- No publicar en issue trackers de otros proyectos (spam).
- No hacer cross-posting masivo; un lugar, un mensaje.
- No afirmar resultados sin que alguien más haya verificado: el estado es "seeking blind verification".
