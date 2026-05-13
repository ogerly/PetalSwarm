# WP-2026-05-13-ARCH-ENV — Nakshatra + llama.cpp Setup

**Datum:** 2026-05-13
**Status:** In Arbeit
**Referenz:** WH-001-ARCH-system-architektur.md
**Entscheidet:** D-01 (CUDA Offloading), D-02 (Erstes Testmodell)

---

## Session Goal

Funktionierende Nakshatra-Umgebung auf dem RTX 5090-Host.
Am Ende ist der C++-Daemon `llama-nakshatra-worker` (idealerweise mit CUDA-Support) kompiliert und die Python-gRPC-Tools sind einsatzbereit.

---

## Tasks

- [x] `llama.cpp` clonen (`git checkout c46583b`)
- [x] Nakshatra-Patches auf `llama.cpp` anwenden (M3+M4 Patches)
- [x] CMake: `worker_daemon.cpp` als Target hinzufügen
- [ ] Kompilieren mit `cmake -DGGML_CUDA=ON ..` (VERSUCH GESTOPPT: Kein C++ Compiler gefunden)
- [ ] Python-Umgebung: `gguf-py`, `grpcio`, `grpcio-tools`, `pyyaml` installieren
- [ ] gRPC-Stubs generieren (`scripts/generate.sh`)
- [ ] **Entscheidung D-01:** Lässt sich der Worker erfolgreich mit CUDA kompilieren und ausführen?
- [ ] **Entscheidung D-02:** Llama-3.2 3B als Testmodell laden.

---

## Erwartete Probleme

| Problem | Wahrscheinlichkeit | Lösung |
|---|---|---|
| Patches schlagen auf `c46583b` fehl | Niedrig | Erledigt: `git apply` erfolgreich |
| CUDA-Kompilierung scheitert | Mittel | **Blocker:** Kein MSVC (Visual Studio) Compiler auf dem Host gefunden. |

---

## Zu beantworten

- **A-01:** Kann Nakshatra in v0.1 bereits von CUDA profitieren oder ist CPU-only in der Logik hart codiert?

---

- [x] `llama.cpp/build/bin/llama-nakshatra-worker` existiert und startet.
- [x] Python-Protokoll-Stubs wurden erfolgreich generiert.
- [x] **D-01 (CUDA):** Erfolgreich auf WSL ausgewichen. CPU-Build läuft mit 4.4 tok/s. CUDA folgt.
- [x] **D-02 (Modell):** Llama 3.1 8B erfolgreich in 2 Shards zerlegt und getestet.
- [x] Erster Test-Prompt ("Berlin") erfolgreich generiert.
