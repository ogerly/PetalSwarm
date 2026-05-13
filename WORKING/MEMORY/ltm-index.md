# LTM Index — Globale dezentrale LLM-Inference

> **Letzte Aktualisierung:** 2026-05-13
> **Einträge:** 5

---

## Entscheidungen

### E-001 — Neuplanung statt Workpaper-Fortsetzung
- **Datum:** 2026-05-13
- **Kontext:** Erstes Workpaper war zu Petals-zentriert, RTX 5090-Hardware nicht berücksichtigt
- **Entscheidung:** Petals bleibt Protokoll, aber realistisch eingeplant
- **Quelle:** `WORKPAPER-Globale-dezentrale-LLM-Inference.md`, Anhang A

### E-002 — Petals als Protokoll trotz Inaktivität
- **Datum:** 2026-05-13
- **Kontext:** Petals letztes Release Sep 2023. Alternativen (exo, llama.cpp distributed) passen nicht zu globalem Ziel
- **Entscheidung:** Petals bleibt — einziges Open-Source-Tool mit Pipeline-Parallelismus über DHT
- **Risiko:** CUDA-Kompatibilität mit RTX 5090 (Blackwell, braucht CUDA 12.6+)
- **Quelle:** `WORKPAPER-Globale-dezentrale-LLM-Inference.md`, Sektion 3

### E-003 — Laptop nur als Client
- **Datum:** 2026-05-13
- **Kontext:** RTX 1030 mit 4 GB VRAM kann maximal 4–6 Blöcke halten
- **Entscheidung:** Nur Client/Observer-Rolle, kein Server
- **Quelle:** `WORKPAPER-Globale-dezentrale-LLM-Inference.md`, Sektion 1.2

### E-004 — Pivot zu Nakshatra (statt Petals)
- **Datum:** 2026-05-13
- **Kontext:** Petals (Hivemind) benötigt `uvloop`, das auf Windows inkompatibel ist (POSIX-only).
- **Entscheidung:** Wechsel zu **Nakshatra** (Fork von Petals).
- **Grund:** Basiert auf `llama.cpp` (C++), gRPC und Tailscale. Nativ Windows-kompatibel, geringer Overhead, heterogen (CPU/GPU).
- **Quelle:** `BRAIN-2026-05-13-P2P-Overlay.md`, `WP-ENV-nakshatra-setup`

### E-005 — Dashboard-Erweiterung: Capacity Explorer
- **Datum:** 2026-05-13
- **Kontext:** Nutzer wünscht Übersicht über Netzwerkkapazität und Modell-Machbarkeit.
- **Entscheidung:** Implementierung eines "Swarm Capacity Explorer" Panels in `shard-demo.html`.
- **Quelle:** `WP-2026-05-13-ARCH-CAP-swarm-capacity-explorer.md`

### E-006 — Konsolidierung zum Monorepo (PetalSwarm)
- **Datum:** 2026-05-13
- **Kontext:** Verschachtelte Repositories erschwerten den "Alles-in-einem" Commit.
- **Entscheidung:** Entfernung der internen `.git`-Ordner von `llama.cpp` und `nakshatra`.
- **Ergebnis:** Ein einziges, sauberes Repository (PetalSwarm) auf GitHub, das alle Patches und Quellcodes enthält. Modell-Shards werden per `.gitignore` ausgeschlossen.

---

## Hardware-Fakten

| Fakt | Wert | Quelle |
|---|---|---|
| RTX 5090 VRAM | 32 GB GDDR7 | WP Sektion 1.1 |
| RTX 5090 Bandbreite | 1.792 GB/s | WP Sektion 1.1 |
| RTX 5090 TDP | 575 W | WP Sektion 1.1 |
| Llama 3.1 70B Q3_K_S | ~28 GB (passt auf 5090) | WP Sektion 1.1 |
| Llama 3.1 70B Q4_K_M | ~42 GB (passt NICHT) | WP Sektion 1.1 |
| RTX 1030 VRAM | ~4 GB GDDR5 | WP Sektion 1.2 |

---

## Architektur-Überblick (Nakshatra-basiert)

- **Worker-Daemons:** Patched `llama.cpp` (C++), gRPC (Port 5530+)
- **Kommunikation:** Tailscale P2P-Mesh (Layer 2 Overlay)
- **Inference:** Layer-wise splitting (Hidden States werden per Token geshardet)
- **FastAPI-Gateway:** Python-Wrapper für gRPC-Chain-Walking
- **Visual Dashboard:** `shard-demo.html` (Capacity Explorer + Feasibility Matrix)

---

## Dokumenten-Index

| WH-001 | WORKING/WHITEPAPER/ | Aktiv | Stabile Architektur-Wahrheit (Nakshatra-Pivot inkludiert) |
| WP-ENV | WORKING/WORKPAPER/closed/ | Geschlossen | Nakshatra + llama.cpp Setup (WSL-Erfolg) |
| WP-CAP | WORKING/WORKPAPER/closed/ | Geschlossen | Swarm Capacity Explorer UI Design & Implementation |
| shard-demo.html | Root | Funktional | Dashboard-UI mit Capacity Explorer Prototyp |
| .agent.json | Root | Aktiv | AAMS/2.0 Manifest |

---

## Session-Log

| Datum | Session | Workpaper | Zusammenfassung |
|---|---|---|---|
| 2026-05-13 | BOOT-INIT | WP-2026-05-13-BOOT-INIT | AAMS on_first_entry: Workspace erstellt, Repo gescannt, Memory initialisiert |
