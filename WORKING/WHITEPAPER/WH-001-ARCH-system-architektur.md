# WH-001 — Systemarchitektur: Globale dezentrale LLM-Inference

> **Typ:** Whitepaper — stabile Architektur-Wahrheit
> **Erstellt:** 2026-05-13
> **Quelle:** Extrahiert aus WORKPAPER-Globale-dezentrale-LLM-Inference.md (Sektionen 0–6, 16)
> **Änderungen nur bei:** Architekturentscheidungen, neue Hardware-Daten, Protokollwechsel

---

## 1. Projektziel

### 1.1 Was "global und dezentral" konkret bedeutet

```
Jeder mit einer GPU kann beitreten.
Jeder mit einem Browser kann anfragen.
Kein einzelner Punkt kontrolliert das System.
```

### 1.2 Drei Ebenen

| Ebene | Beschreibung | Status |
|---|---|---|
| **Verstehen (Analyse)** | Was passiert technisch bei verteilter Inference? | Ziel dieses Projekts |
| **Demonstrieren (PoC)** | Sichtbares System: Topologie live, Anfragen messbar | Ziel dieses Projekts |
| **Betreiben** | Externe Peers einladen, echte Redundanz | Nächstes Projekt |

---

## 2. Hardware-Realität

### 2.1 Primärknoten — RTX 5090

| Eigenschaft | Wert | Bedeutung für Inference |
|---|---|---|
| VRAM | 32 GB GDDR7 | Llama 3 70B bei Q3_K_S (~28 GB) passt gerade |
| Speicherbandbreite | 1.792 GB/s | 78% mehr als RTX 4090 — entscheidend für tok/s |
| Architektur | Blackwell (TSMC 4NP) | Nativ FP4, 5th-gen Tensor Cores |
| TDP | 575 W | PSU 1200W+ nötig |
| Realistische tok/s (32B Q4) | 60–70 tok/s | Standalone stark |
| Realistische tok/s (70B Q3) | ~15–20 tok/s | Grenzwertig allein, gut im Swarm |

**Kritischer Befund:** Q4_K_M (~42 GB) passt NICHT auf den 5090. Der 5090 ist standalone ein starker 32B-Knoten und ein grenzwertiger 70B-Knoten. Im Swarm wird er zum dominanten Anker.

### 2.2 Sekundärknoten — Laptop RTX 1030

| Eigenschaft | Wert | Bedeutung |
|---|---|---|
| VRAM | ~4 GB GDDR5 | Sehr begrenzt |
| Nutzbarkeit im Swarm | Embedding-Layer, 2–4 Blöcke maximal | Symbolisch, nicht performant |
| **Realistische Rolle** | **Nur Client/Observer** | Dashboard, API-Tests |

---

## 3. Protokollwahl

### 3.1 Bewertung

| Protokoll | Ansatz | Stand 2026 | Für dieses Ziel |
|---|---|---|---|
| **Nakshatra** | Layer-wise splitting, gRPC, llama.cpp-basiert | **Aktiv**, v0.1 funktional | ✅ Perfekter Match |
| **Petals** | Pipeline-Parallelismus, DHT, PyTorch | Letztes Release Sep 2023 | ❌ Nativ inkompatibel (uvloop/Windows) |
| exo | Pipeline + Tensor-Parallelismus, heterogen | Aktiv, primär LAN | ❌ Kein globaler Swarm |
| llama.cpp distributed | Tensor-Split, multi-GPU | Kein P2P, kein DHT | ❌ Kein dezentrales Netz |

### 3.2 Entscheidung

**Nakshatra ersetzt Petals als technisches Fundament.** 
Der ursprüngliche Versuch mit Petals schlug auf Consumer-Systemen (Windows) fehl, da das Kernpaket `hivemind` (bzw. `uvloop`) Kernel-Features von POSIX voraussetzt. 
Nakshatra basiert auf `llama.cpp` und C++, umgeht den PyTorch-Overhead vollständig und nutzt simples gRPC über Tailscale. Es ist schlanker, robuster und plattformunabhängig.

### 3.3 Neue Strategie: Bootstrap-Architektur (PetalSwarm Lean Mode)

Statt die kompletten Abhängigkeiten (`llama.cpp`, `nakshatra`) im Repository zu hosten, nutzt PetalSwarm einen **Lean-Approach**:
1. **Repository:** Enthält nur eigenen Code, Patches, Dokumentation und Konfigurationen.
2. **setup.sh (Bootstrap):** Ein WSL-Skript clont die Repos, wendet Patches an und baut die Binaries.
3. **Plattform:** **WSL2 (Ubuntu)** ist die primäre Runtime-Umgebung für Windows-Hosts, um POSIX-Kompatibilität und Performance zu garantieren.
4. **Modelle:** Sharding erfolgt lokal via Python; `.gguf`-Dateien werden strikt per `.gitignore` ausgeschlossen.

---

## 4. Modellwahl

### 4.1 VRAM-Kalkulation

```
Llama 3.1 70B: 80 Transformer-Blöcke
Q3_K_S ~ 28 GB → passt auf RTX 5090 (32 GB)
Q4_K_M ~ 42 GB → passt NICHT auf RTX 5090

RTX 5090 (32 GB)  → alle 80 Blöcke allein ODER 50–60 im Swarm
Peer RTX 3090/4090 (24 GB) → ~55 Blöcke
Laptop RTX 1030 (4 GB) → maximal 4–6, nur Embedding
```

### 4.2 Modell-Empfehlungen

| Phase | Modell | Grund |
|---|---|---|
| Phase 1 (PoC) | `bigscience/bloom-560m` oder `meta-llama/Llama-3.2-3B` | Klein, schnell, Fehler isolierbar |
| Phase 2 (Ziel) | `meta-llama/Meta-Llama-3.1-70B-Instruct` | Im Petals-Swarm supported, Q3_K_S passt |

---

## 5. Systemarchitektur

```
┌─────────────────────────────────────────────────────────┐
│                    INTERNET / TAILSCALE                 │
└───────────────────┬─────────────────────────────────────┘
                    │
         ┌──────────▼───────────┐
         │   TAILSCALE MESH     │  ← VPN-Overlay
         │   (Statisches IP-Netz│    Sichere, NAT-übergreifende
         │   für v0.1 Cluster)  │    Verbindungen
         └──────────┬───────────┘
                    │  gRPC
          ┌─────────┴──────────┐
          │                    │
┌─────────▼──────┐   ┌─────────▼──────┐
│  NAKSHATRA WKR  │   │  NAKSHATRA WKR  │  ← externe Peers
│  RTX 5090       │   │  (Peer Hardware)│
│  Layer 0-13     │   │  Layer 14-27    │
└─────────┬───────┘   └─────────┬───────┘
          └─────────┬───────────┘
                    │
        ┌───────────▼───────────┐
        │   FastAPI GATEWAY     │  ← Client: Tokenisiert & walkt Chain
        │   /v1/chat/completions│    Port 8000
        │   (Python gRPC Wrapper│
        └───────────┬───────────┘
                    │
        ┌───────────▼───────────┐
        │   VISUAL DASHBOARD    │  ← Browser-basiert
        │   shard-demo.html     │    (Vanilla JS, Web Components)
        └───────────────────────┘

### 5.1 Deployment & Build (WSL2)

```bash
# Swarm Genesis Command
wsl -d Ubuntu ./setup.sh
```
Das Setup-Skript garantiert die Reproduzierbarkeit der Build-Umgebung inklusive aller Patches für llama.cpp.
```

---

## 6. Netzwerk-Anforderungen

### 6.1 Ports / Protokolle

| Port/Proto | Dienst |
|---|---|
| Tailscale | Overlay-Netzwerk für v0.1 Worker |
| 50051/tcp | gRPC Nakshatra Worker (Default) |
| 8000/tcp | FastAPI Gateway |
| 3000/tcp | Visual Dashboard (Dev) |

### 6.2 Bandbreite

```
Pro Token: ~12-16 KB Hidden States (bei 3B-70B)
Bei 10 tok/s: Extrem niedrig (<< 1 MB/s)
Das ist die Kernstärke von Nakshatra: Minimaler Netzwerktraffic.
```

### 6.3 Erreichbarkeits-Optionen

| Option | Aufwand | Stabilität | Phase |
|---|---|---|---|
| Tailscale (WireGuard-Mesh) | Sehr niedrig | Sehr gut | **Gewählt für v0.1** |
| Öffentliches gRPC | Mittel | Akzeptabel | Später |

---

## 7. Risiken

| Risiko | Wahrsch. | Bedeutung | Umgang |
|---|---|---|---|
| Nakshatra Setup-Komplexität | **GELÖST** | Mittel | Automatisiert durch `setup.sh` |
| Bisher nur CPU-Support bewiesen | **VERIFIZIERT** | Hoch | 4.4 tok/s auf CPU (Llama 3.1 8B) erreicht. GPU folgt. |
| Client als Single Point of Failure | Hoch | Mittel | Für PoC-Phase 1 akzeptiert |
| KV-Cache nicht geteilt (Latency) | Hoch | Mittel | Bekanntes Limit in v0.1, akzeptiert |
| 70B Setup in Nakshatra zu komplex | Mittel | Hoch | Test mit 8B erfolgreich abgeschlossen. |

---

## 8. Analysefragen

Diese Fragen werden in den zugehörigen Workpapers beantwortet:

| # | Frage | Zugehöriges WP |
|---|---|---|
| A-01 | Python/PyTorch/CUDA-Version für RTX 5090? | WP-ENV |
| A-02 | Wie viele Blöcke hält der 5090 bei Q3_K_S? | WP-SCALE |
| A-03 | tok/s als Single-Node? | WP-BOOT |
| A-04 | tok/s-Änderung mit zweitem Peer? | WP-SCALE |
| A-05 | Was geht übers Netzwerk? | WP-BOOT |
| A-06 | Verhalten bei Peer-Ausfall? | WP-SCALE |
| A-07 | Ist der öffentliche Swarm noch aktiv? | WP-ENV |
| A-08 | Tailscale als Bootstrap-Relay? | WP-SCALE |
| A-09 | Upload-Bandbreite als Flaschenhals? | WP-SCALE |
| A-10 | shard-demo.html ohne Framework verdrahtbar? | WP-DASH |

---

*Dieses Whitepaper wird nur bei Architekturentscheidungen aktualisiert.*
*Task-Details stehen in den zugehörigen Workpapers.*
