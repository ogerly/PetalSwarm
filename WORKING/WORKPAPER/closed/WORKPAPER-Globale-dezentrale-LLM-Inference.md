# WORKPAPER — Globale dezentrale LLM-Inference

## Neuplanung & Architektur auf Basis RTX 5090 + Petals-Protokoll

**Datum:** 2026-05-13
**Status:** Aktiv — erster Planungsblock
**Ersetzt:** Workpaper-Petals-AAMS-verteiltesLLM.md (zu Petals-zentriert, veraltete Annahmen)
**Projekt:** dezentrale-inference-global

---

## 0. Warum ein Neustart

Das erste Workpaper war solid in der Methodik, aber Petals-zentriert. Petals ist das richtige
Konzept (Pipeline-Parallelismus, DHT, BitTorrent-Prinzip), aber kein aktives Projekt mehr.
Letztes Release: September 2023. Letzter relevanter PR: September 2024, nie gemergt.

Das neue Workpaper:

- Behält das Ziel: globale, dezentrale Inference sichtbar machen
- Behält AAMS als Dokumentationsstruktur
- Baut auf realer Hardware auf (RTX 5090 + Laptop RTX 1030)
- Wählt das Protokoll nach aktuellem Stand, nicht nach historischen Annahmen
- Plant realistisch, was mit dieser Hardware allein und mit Peers möglich ist

---

## 1. Hardware-Realität

### 1.1 Primärknoten — RTX 5090

| Eigenschaft | Wert | Bedeutung für Inference |
|---|---|---|
| VRAM | 32 GB GDDR7 | Llama 3 70B bei Q3_K_S (~28 GB) passt gerade |
| Speicherbandbreite | 1.792 GB/s | 78% mehr als RTX 4090 — entscheidend für tok/s |
| Architektur | Blackwell (TSMC 4NP) | Nativ FP4, 5th-gen Tensor Cores |
| TDP | 575 W | PSU 1200W+ nötig |
| Realistische tok/s (32B Q4) | 60–70 tok/s | Standalone stark |
| Realistische tok/s (70B Q3) | ~15–20 tok/s | Grenzwertig allein, gut im Swarm |

**Kritischer Befund:** Der 5090 kann Llama 3 70B in Q3_K_S (~28 GB) auf einer Karte halten.
Q4_K_M (~42 GB) passt nicht — zu groß um ~10 GB. Der 5090 ist also standalone ein starker
32B-Knoten und ein grenzwertiger 70B-Knoten. Im dezentralen Swarm wird er zum dominanten
Anker für größere Modelle.

### 1.2 Sekundärknoten — Laptop RTX 1030

| Eigenschaft | Wert | Bedeutung |
|---|---|---|
| VRAM | ~4 GB GDDR5 | Sehr begrenzt |
| Nutzbarkeit im Swarm | Embedding-Layer, 2–4 Blöcke maximal | Symbolisch, nicht performant |
| Realistische Rolle | Beobachter/Client, nicht Server | Für das Dashboard sinnvoll |

**Ehrliche Einschätzung:** Der Laptop-Node trägt zum Swarm kaum bei. Er ist wertvoll als
Client-Knoten: Dashboard laufen lassen, Metriken beobachten, API-Calls testen. Den 1030
als Petals-Server einzurichten würde mehr Probleme machen als lösen.

---

## 2. Ziel — neu formuliert

### 2.1 Was "global und dezentral" hier konkret bedeutet

Kein proprietäres Netzwerk. Kein festes Rechenzentrum. Stattdessen:

```
Jeder mit einer GPU kann beitreten.
Jeder mit einem Browser kann anfragen.
Kein einzelner Punkt kontrolliert das System.
```

Das ist das Petals-Prinzip — und es bleibt das Ziel.
Die Frage ist nur, mit welchem Stack man es 2026 umsetzt.

### 2.2 Drei Ebenen des Ziels

**Ebene 1 — Verstehen (Analyse)**
Was passiert technisch bei verteilter Inference? Wer hostet welche Blöcke?
Wie verhält sich Latenz, Bandbreite, Peer-Ausfall?

**Ebene 2 — Demonstrieren (PoC)**
Ein sichtbares System: Swarm-Topologie live, Anfragen messbar, Kosten vergleichbar.
Die `shard-demo.html` ist hierfür das fertige UI-Fundament.

**Ebene 3 — Betreiben (optional, später)**
Andere laden ein. Eigene Nodes schließen sich an. Echte Redundanz entsteht.

Das erste Workpaper zielt auf Ebene 1 + 2. Ebene 3 ist das nächste Workpaper.

---

## 3. Protokollwahl — ehrliche Bewertung

### 3.1 Kandidaten

| Protokoll | Ansatz | Stand 2026 | Für dieses Ziel |
|---|---|---|---|
| **Petals** | Pipeline-Parallelismus, DHT, Python/PyTorch | Letztes Release Sep 2023, ruhig aber lauffähig | ✅ Konzept passt exakt |
| **exo** | Pipeline + Tensor-Parallelismus, heterogen | Aktiv, aber primär LAN/lokaler Cluster | ❌ Kein globaler Swarm-Modus |
| **llama.cpp distributed** | Tensor-Split, multi-GPU | Kein P2P, kein DHT | ❌ Kein dezentrales Netz |
| **Eigenbau auf hivemind** | DIY auf der DHT-Library die Petals nutzt | Möglich, aber viel Aufwand | ⚠️ Für Phase 2 |

**Entscheidung: Petals bleibt das technische Fundament.**

Begründung: Petals ist das einzige fertige Open-Source-System das genau das tut was gefordert
ist — Pipeline-Parallelismus über ein öffentliches DHT-Netz, public oder private Swarm,
Python-kompatibel, HuggingFace-Modelle. Die Inaktivität ist ein Risiko, kein Blocker.

### 3.2 Umgang mit dem Alters-Risiko

Petals wurde auf Python 3.10, PyTorch 2.0, CUDA 11.7/12.1 entwickelt.
Der 5090 braucht CUDA 12.6+ für volle Blackwell-Unterstützung. Möglicher Konflikt.

**Strategie:**

1. Erst in Conda-Umgebung mit Python 3.10 + PyTorch 2.1 + CUDA 12.1 testen.
2. Wenn das bricht: hivemind und petals Dependencies isoliert pinnen.
3. Wenn der 5090 native CUDA 12.6 braucht: PyTorch nightly oder Petals-Fork evaluieren.
4. Alle Probleme exakt im MEMORY dokumentieren.

---

## 4. Modellwahl

### 4.1 Für den ersten PoC (Phase 1)

**Empfehlung: `bigscience/bloom-560m` oder `meta-llama/Llama-3.2-3B`**

Warum klein anfangen:

- Ziel ist Architektur-Verständnis, nicht Modellqualität
- Kleine Modelle starten schnell, laufen auch ohne perfekte CUDA-Version
- Fehler sind isolierbar

### 4.2 Für das eigentliche Ziel (Phase 2)

**Empfehlung: `meta-llama/Meta-Llama-3.1-70B-Instruct`**

Warum:

- Llama 3.1 70B ist im öffentlichen Petals-Swarm aktiv supported
- In Q3_K_S passt es auf den 5090 (allein als Single-Node)
- Im Swarm mit weiteren Peers: Q4_K_M möglich wenn Nodes zusammen >48 GB VRAM bieten

### 4.3 VRAM-Verteilung im Swarm (Llama 3.1 70B)

```
Llama 3.1 70B hat 80 Transformer-Blöcke.
Q3_K_S ~ 28 GB gesamt.

RTX 5090 (32 GB)  → kann alle 80 Blöcke allein halten (Single-Node-Modus)
                  → oder 50–60 Blöcke im Swarm-Modus (gibt Blöcke ab)

Peer mit RTX 3090 (24 GB) → kann ~55 Blöcke halten
Peer mit RTX 4090 (24 GB) → kann ~55 Blöcke halten
Peer mit 2x RTX 3090 (48 GB) → kann alle Blöcke halten

Laptop RTX 1030 (4 GB) → maximal 4–6 Blöcke, nur Embedding sinnvoll
```

---

## 5. Architektur des Gesamtsystems

### 5.1 Komponenten

```
┌─────────────────────────────────────────────────────────┐
│                    INTERNET / WAN                        │
└───────────────────┬─────────────────────────────────────┘
                    │
        ┌───────────▼───────────┐
        │   BOOTSTRAP PEER      │  ← öffentlich erreichbar
        │   (DHT Koordination)  │    Port 31337 (TCP)
        │   läuft auf 5090-Host │    statische IP oder DynDNS
        └───────────┬───────────┘
                    │  initial_peers
          ┌─────────┴──────────┐
          │                    │
┌─────────▼──────┐   ┌─────────▼──────┐
│  PETALS SERVER  │   │  PETALS SERVER  │  ← externe Peers
│  RTX 5090       │   │  (Peer GPU)     │
│  ~50-80 Blöcke  │   │  ~20-50 Blöcke  │
└─────────┬───────┘   └─────────┬───────┘
          └─────────┬───────────┘
                    │
        ┌───────────▼───────────┐
        │   FastAPI GATEWAY     │  ← OpenAI-kompatibel
        │   /v1/chat/completions│    läuft auf 5090-Host
        │   /health             │
        │   /swarm/status       │
        │   /metrics            │
        └───────────┬───────────┘
                    │
        ┌───────────▼───────────┐
        │   VISUAL DASHBOARD    │  ← Browser-basiert
        │   (shard-demo.html    │    Basis für Vue-Port
        │    verdrahtet)        │
        └───────────────────────┘
                    │
        ┌───────────▼───────────┐
        │   LAPTOP (1030)       │  ← Client/Observer
        │   Dashboard-Browser   │    keine Server-Rolle
        └───────────────────────┘
```

### 5.2 Was "global" hier operativ bedeutet

Der Bootstrap-Peer muss öffentlich erreichbar sein. Drei realistische Optionen:

| Option | Aufwand | Stabilität | Empfehlung |
|---|---|---|---|
| Statische IP + Port-Forwarding | Niedrig | Gut | ✅ Wenn vorhanden |
| DynDNS + Port-Forwarding | Niedrig | Akzeptabel | ✅ Als Fallback |
| Tailscale (privates WireGuard-Mesh) | Sehr niedrig | Sehr gut | ✅ Für erste Tests |
| VPS als Bootstrap-Relay | Mittel | Sehr gut | Für Phase 2 |

**Empfehlung Phase 1:** Tailscale für einfaches privates Netz zwischen eigenen Geräten.
**Empfehlung Phase 2:** Port-Forwarding oder kleiner VPS (5$/Monat) als dauerhafter Bootstrap.

---

## 6. Netzwerk-Anforderungen

### 6.1 Ports

```
31337/tcp  → Bootstrap Peer (DHT)
31330/tcp  → Petals Server Node
8000/tcp   → FastAPI Gateway
3000/tcp   → Visual Dashboard (Dev)
```

### 6.2 Bandbreite

Petals überträgt Aktivierungen (keine Modellgewichte) zwischen Nodes.
Für Llama 3.1 70B gilt grob:

```
Pro Token: ~4–8 MB Aktivierungen zwischen Blöcken (bfloat16)
Bei 10 tok/s: ~40–80 MB/s zwischen Nodes nötig
Für LAN: kein Problem
Für WAN: 100 Mbit/s Upload empfohlen, 1 Gbit/s ideal
```

Der 5090-Host braucht guten Upload. Typische DSL/VDSL-Verbindungen (50 Mbit Upload)
werden zum Flaschenhals — das ist ein bekannter Petals-Befund.

---

## 7. Repository-Struktur (neu)

```
dezentrale-inference/
├── .agent.json
├── README.md
├── docker-compose.yml
├── .env.example
│
├── WORKING/
│   ├── WHITEPAPER/
│   │   ├── 000-system-kontext.md
│   │   ├── 010-protokoll-vergleich.md      ← Petals vs exo vs hivemind DIY
│   │   ├── 020-hardware-analyse.md         ← RTX 5090 Kapazitäten, Benchmarks
│   │   ├── 030-netzwerk-topologie.md       ← Bootstrap, NAT, WAN-Anforderungen
│   │   └── 040-modell-auswahl.md           ← VRAM-Kalkulationen, Quantisierung
│   ├── WORKPAPER/
│   │   ├── 2026-05-13-neuplanung.md        ← dieses Dokument
│   │   └── closed/
│   └── MEMORY/
│       ├── ltm-index.md
│       ├── decisions.md
│       └── events.jsonl
│
├── infra/
│   ├── bootstrap/
│   │   ├── run-bootstrap.sh
│   │   └── README.md
│   ├── server/
│   │   ├── run-server.sh
│   │   └── README.md
│   └── scripts/
│       ├── install-env.sh
│       ├── test-client.py
│       └── check-swarm.py               ← neu: Swarm-Health-Check
│
├── gateway/                             ← FastAPI, OpenAI-kompatibel
│   ├── app.py
│   ├── requirements.txt
│   └── README.md
│
├── dashboard/                           ← aus shard-demo.html entwickelt
│   ├── index.html                       ← Phase 1: shard-demo.html verdrahtet
│   └── src/                             ← Phase 2: Vue-Komponenten
│
└── docs/
    ├── setup-guide.md
    ├── joining-the-swarm.md             ← für externe Peers
    └── observations/
```

---

## 8. AAMS `.agent.json`

```json
{
  "project": "dezentrale-inference-global",
  "version": "0.2.0",
  "purpose": "Globale dezentrale LLM-Inference mit Petals-Protokoll aufbauen und sichtbar machen",
  "agent_mode": "documentation_first",
  "rules": {
    "document_every_session": true,
    "no_large_code_without_workpaper": true,
    "prefer_private_swarm_for_testing": true,
    "never_send_sensitive_data_to_public_swarm": true,
    "hardware_constraints_are_hard_limits": true
  },
  "hardware": {
    "primary_node": {
      "gpu": "RTX 5090",
      "vram_gb": 32,
      "role": "bootstrap + server + gateway"
    },
    "secondary_node": {
      "gpu": "RTX 1030",
      "vram_gb": 4,
      "role": "client + dashboard observer only"
    }
  },
  "folders": {
    "whitepaper": "WORKING/WHITEPAPER",
    "workpaper": "WORKING/WORKPAPER",
    "memory": "WORKING/MEMORY"
  },
  "model_targets": {
    "phase_1_test": "bigscience/bloom-560m",
    "phase_2_target": "meta-llama/Meta-Llama-3.1-70B-Instruct",
    "quantization": "Q3_K_S"
  },
  "network": {
    "bootstrap_port": 31337,
    "server_port": 31330,
    "gateway_port": 8000,
    "public_mode": "tailscale_first_then_port_forward"
  }
}
```

---

## 9. FastAPI Gateway — Endpunkte

Das Gateway ist die einzige Schicht die nach außen zeigt. Clients sprechen nie direkt Petals an.

```
GET  /health                   → Status Gateway + Swarm-Verbindung
GET  /v1/models                → Liste verfügbarer Modelle (OpenAI-kompatibel)
POST /v1/chat/completions      → Inference (OpenAI-kompatibel, streaming)
GET  /swarm/status             → aktive Nodes, Blöcke, VRAM je Peer
GET  /swarm/peers              → Peer-Liste mit public_name, Blöcke, Latenz
GET  /metrics                  → tok/s, Latenz, Fehlerrate (Prometheus-Format)
GET  /memory/events            → letzte N Events aus events.jsonl
POST /memory/events            → Event schreiben
```

**Wichtig:** Der `/v1/chat/completions`-Endpunkt muss OpenAI-kompatibel sein.
Das erlaubt jedem OpenAI-Client (Continue, Cursor, eigene Apps) den Swarm zu nutzen
ohne Änderungen.

---

## 10. Visual Dashboard

### 10.1 Ausgangspunkt: `shard-demo.html`

Die hochgeladene `shard-demo.html` hat bereits:

- Animiertes P2P-Mesh (Canvas)
- Chat-Interface mit Metriken
- Live-Stats-Sidebar
- Kostenvergleich-Panel

**Phase 1:** `shard-demo.html` nehmen, Fake-Daten durch echte `fetch()`-Calls ersetzen.
Kein Vue, kein Build-System. Direktes HTML/JS gegen das FastAPI Gateway.

**Phase 2:** Vue 3 + Vite, `shard-demo.html` als Design-Referenz.

### 10.2 Dashboard-Panels (Zielzustand)

```
┌──────────────────┬──────────────────┬──────────────────┐
│  SWARM TOPOLOGY  │   CHAT / PROMPT  │   LIVE METRICS   │
│                  │                  │                  │
│  animiertes Mesh │  Eingabe         │  tok/s           │
│  Nodes mit Namen │  Antwort         │  Latenz          │
│  Blöcke je Node  │  Laufzeit        │  Nodes aktiv     │
│  Verbindungslinien│  Token-Count    │  VRAM je Peer    │
│                  │                  │  Bandbreite      │
├──────────────────┴──────────────────┼──────────────────┤
│         AAMS MEMORY PANEL           │  COST COMPARISON │
│                                     │                  │
│  aktuelle Session                   │  Cloud API       │
│  letzte Events                      │  vs. Swarm       │
│  offene Entscheidungen              │  (live)          │
│  Workpaper-Links                    │                  │
└─────────────────────────────────────┴──────────────────┘
```

---

## 11. Memory — Event-Format

```jsonl
{"timestamp":"2026-05-13T10:00:00Z","type":"install","result":"success","notes":"Petals installiert auf Python 3.10, CUDA 12.1","duration_s":null}
{"timestamp":"2026-05-13T10:15:00Z","type":"bootstrap_start","peer_id":"12D3Koo...","port":31337,"result":"success"}
{"timestamp":"2026-05-13T10:20:00Z","type":"server_start","model":"bigscience/bloom-560m","blocks":12,"vram_used_gb":1.2,"result":"success"}
{"timestamp":"2026-05-13T10:30:00Z","type":"inference_test","model":"bigscience/bloom-560m","prompt_chars":64,"duration_s":3.2,"tokens_generated":80,"tok_per_s":25.0,"result":"success"}
{"timestamp":"2026-05-13T10:35:00Z","type":"peer_joined","peer_name":"remote-peer-1","blocks":8,"vram_gb":24}
```

---

## 12. Analysefragen (aktualisiert)

Diese Fragen sollen während der Umsetzung beantwortet werden:

1. Mit welcher Python/PyTorch/CUDA-Version läuft Petals auf dem RTX 5090 stabil?
2. Wie viele Blöcke von Llama 3.1 70B kann der 5090 bei Q3_K_S halten?
3. Wie viele tok/s erreicht der Swarm mit dem 5090 als Single-Node?
4. Wie ändert sich tok/s wenn ein zweiter Peer 20 Blöcke übernimmt?
5. Was geht tatsächlich über das Netzwerk — Aktivierungen, Gewichte, oder beides?
6. Wie verhält sich das System bei Peer-Ausfall während einer laufenden Inference?
7. Ist der öffentliche Petals-Swarm (health.petals.dev) noch aktiv?
8. Wie stabil ist Tailscale als Bootstrap-Relay für WAN-Peers?
9. Welche Upload-Bandbreite ist tatsächlich der Flaschenhals?
10. Kann `shard-demo.html` ohne Framework sinnvoll verdrahtet werden?

---

## 13. Phasenplan

### Phase 1 — Fundament (Woche 1)

- [ ] Repository-Struktur anlegen
- [ ] Conda-Umgebung: Python 3.10, PyTorch 2.1, CUDA 12.1
- [ ] Petals installieren, Probleme dokumentieren
- [ ] Bootstrap-Peer starten, Peer-ID sichern
- [ ] Petals-Server mit bloom-560m starten
- [ ] Ersten Inference-Test durchführen
- [ ] FastAPI Gateway Grundgerüst (`/health`, `/swarm/status`)
- [ ] `shard-demo.html` gegen echte Endpunkte verdrahten

### Phase 2 — Erweiterung (Woche 2-3)

- [ ] Llama 3.1 70B Q3_K_S auf 5090 testen
- [ ] `/v1/chat/completions` OpenAI-kompatibel implementieren
- [ ] Tailscale-Setup für WAN-Peers
- [ ] Ersten externen Peer einladen
- [ ] Swarm-Topologie live im Dashboard
- [ ] `joining-the-swarm.md` für Externe schreiben

### Phase 3 — Skalierung (offen)

- [ ] VPS als dauerhafter Bootstrap-Peer
- [ ] Port-Forwarding für echte Public-Erreichbarkeit
- [ ] Vue 3 Dashboard-Refactor
- [ ] Prometheus Metriken
- [ ] Modell-Auswahl im Dashboard

---

## 14. Offene Entscheidungen

| # | Frage | Optionen | Status |
|---|---|---|---|
| D-01 | CUDA-Version für 5090 | 12.1 (Petals-getestet) vs. 12.6 (Blackwell-nativ) | offen |
| D-02 | Erstes Testmodell | bloom-560m vs. Llama 3.2 3B | offen |
| D-03 | Bootstrap-Zugang | Tailscale vs. Port-Forward | offen |
| D-04 | Dashboard-Start | shard-demo.html direkt vs. sofort Vue | offen |
| D-05 | Laptop-Rolle | nur Client vs. embedding-layer versuchen | offen — vermutlich nur Client |

---

## 15. Definition of Done — Phase 1

Phase 1 ist abgeschlossen wenn:

- [ ] Petals läuft auf RTX 5090 (oder Installationsprobleme exakt dokumentiert)
- [ ] Ein Inference-Test mit bloom-560m war erfolgreich
- [ ] FastAPI-Gateway antwortet auf `/health` und `/swarm/status`
- [ ] `shard-demo.html` zeigt echte Daten aus dem Gateway
- [ ] Alle Events in `events.jsonl` geschrieben
- [ ] Mindestens eine Entscheidung aus D-01 bis D-05 dokumentiert getroffen
- [ ] `000-system-kontext.md` und `020-hardware-analyse.md` im Whitepaper vorhanden

---

## 16. Risiken (aktualisiert)

| Risiko | Wahrscheinlichkeit | Bedeutung | Umgang |
|---|---|---|---|
| Petals bricht auf RTX 5090 wegen CUDA-Version | Hoch | Mittel | CUDA 12.1 erzwingen in Conda |
| hivemind-Dependency veraltet | Mittel | Mittel | Version pinnen, Issue tracken |
| Öffentlicher Swarm inaktiv | Mittel | Niedrig | Private Swarm ist Plan A |
| Upload-Bandbreite limitiert tok/s | Hoch (bei WAN) | Mittel | Erst LAN/Tailscale |
| 70B passt nicht bei Q3_K_S in 32 GB | Niedrig | Hoch | Fallback: 34B oder kleineres Modell |
| Laptop-Node ist nutzlos als Server | Sehr hoch | Niedrig | Akzeptiert — nur Client-Rolle |

---

## Anhang A — Entscheidungsprotokoll

```
2026-05-13  ENTSCHEIDUNG: Neuplanung statt Workpaper-Fortsetzung
            GRUND: Petals zu alt als alleinige Grundlage, Hardware-Realität (5090)
            war nicht berücksichtigt, exo passt nicht zu globalem Ziel
            ERGEBNIS: Petals bleibt Protokoll, aber realistisch eingeplant
```

---

*Nächster Schritt: Repository-Struktur anlegen + Install-Session starten.*
*Alle Probleme in WORKING/MEMORY/events.jsonl dokumentieren.*
