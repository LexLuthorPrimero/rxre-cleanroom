# RXRE — Protocolo de sellar-antes-de-revelar para reconstrucción semántica

Versión 1.0 (2026-11-12). Propósito: reconstruir una función de un binario real, sin leer
código fuente, de modo que **cualquier tercero** pueda refutarla con una prueba diferencial.

## 0. Presupuestos
- El binario es un artefacto observado (p. ej., `/usr/bin/ls`): se identifica por sha256 + BuildID + tamaño + BuildID; se conserva el binario observado, nunca se modifica.
- No se lee ni se deriva el fuente del proyecto analizado (sin Ghidra del proyecto, sin paquetes fuente, sin descompilación causal completa previa): la hipótesis se deriva del **comportamiento observado**.

## 1. Hipótesis contra experimento
1. Identificar las funciones candidatas (vaddrs, fronteras, `endbr64`, llamadas directas) con `objdump -d`.
2. Formular una hipótesis estructural **con predicciones falsables**: qué debe producir el binario para una familia de entradas.
3. Escribir el corpus **antes** de ejecutar cualquier oráculo:
   - familias estructurales (casos límite: vacíos, punto inicial/interior, runs de dígitos, `~`, bytes altos, extensiones dpkg-style) + muestras aleatorias balanceadas;
   - semilla fija y pública; generador versionado con el paquete.
4. **sellar el corpus**: `sha256sum corpus > corpus.sha256` y registrar la fecha ANTES de tocar el oráculo o el código.

## 2. Oráculo independiente
5. El "oráculo" es el binario real cargado por `mmap` (solo lectura), invocado con las entradas del corpus sellado; nunca el análisis estático.
6. Registrar matriz de resultados: un entero por caso (`%d\n`), sin tolerancia.
7. Sellar la matriz (`matrix.sha256`) antes de escribir/editar la reconstrucción.

## 3. Reconstrucción
8. Transcribir el desensamblado a un lenguaje legible con correspondencia instrucción↔línea trazable (comentarios con direcciones `0x…`). El código debe capturar **magnitudes exactas**, no signos.
9. Compilar con advertencias estrictas (`-Wall -Wextra -pedantic -Werror`).

## 4. Diferencial a cero tolerancia
10. Ejecutar: `./verify2 corpus matrix` — exige coincidencia **int exacta** en 100 % de los casos.
11. Ante divergencias: clasificar por familias (no por salida), decodificar la rama del binario responsable, corregir el código (nunca relajar el criterio), re-ejecutar.
12. Criterio de cierre del corpus: **cero divergencias** en la generación sellada.

## 5. Segunda generación y sellado
13. Nuevo corpus con semilla distinta (p. ej. 20261113) y mismo procedimiento 1–10; ambas generaciones deben dar cero divergencias.
14. Toda documentación declara las restricciones y no promueve etiquetas (`VERIFIED`, `PASS PARTIAL`, `BLOCKED`, `NOT_DETERMINED`) sin la cadena completa.

## 6. Terceros
15. El método solo se completa con un tercero que ejecute los pasos 1–10 sin intervención del autor, en su propio host, y publique su resultado. Hasta entonces, el dictamen del autor no vale como tercero.

## 7. Formato de expediente (sellado)
- Identidad del binario (hashes), corpus + sello, oráculo + sello, reconstrucción (hash), harness (hash), toolchain(s), salidas, limitaciones, etiqueta (OPEN / PASS PARTIAL / PASS) — **nunca** PASS sin el paso 15.

## 8. Lecciones de un caso real (filenvercmp, GNU coreutils)
- Un modelo empírico de "bytes ordenan así" pasa chequeos de byte único (0/32.385) y aun así falla en 791/34.145 pares por cadenas de extensión `.` — los chequeos de componente no implican corrección de la cadena completa.
- Un 20.000-caso aleatorio pasó mientras el corpus estructurado fallaba: el muestreo debe cubrir las **familias** que el binario distingue, no solo densidad uniforme.
- Las magnitudes exactas importan para int-exacta: `302` vs `1` es distinción, no estética.
