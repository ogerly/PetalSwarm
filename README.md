# 🌸 PetalSwarm

> **Global Decentralized LLM Inference Swarm**
> *Building a P2P neural network for massive Transformer models across heterogeneous hardware.*

---

## 🚀 Vision

PetalSwarm ist ein dezentrales Inferenz-Netzwerk, das es ermöglicht, modernste LLMs (wie Llama 3.1 70B/405B) auf Consumer-Hardware zu betreiben. Durch das Aufteilen der Modell-Layer auf verschiedene Knoten (Sharding) im Netzwerk kann selbst eine einzelne RTX 5090 Teil eines globalen Supercomputers werden.

## 🏗️ Architektur

Das System basiert auf einer spezialisierten Architektur (Nakshatra), die das Beste aus zwei Welten kombiniert:
- **Core:** Hochoptimierte C++ Worker-Daemons basierend auf `llama.cpp`.
- **Kommunikation:** Schlankes gRPC-Protokoll für minimalen Overhead bei der Übertragung von Hidden States.
- **Netzwerk:** P2P-Overlay (Tailscale/Mesh) für sichere, dezentrale Konnektivität.
- **Hardware:** Volle Unterstützung für NVIDIA (CUDA) und heterogene CPU-Knoten.

## 📊 Status: Phase 2 (Infrastructure & Swarm Genesis)

- [x] **WSL2 Integration:** Stabiler Linux-Build-Prozess für Windows-Hosts.
- [x] **Model Sharding:** Erfolgreiches Zerlegen von Llama 3.1 8B in funktionale Sub-GGUFs.
- [x] **Local Swarm Success:** Erster dezentraler Token-Flow zwischen zwei lokalen Workern verifiziert.
- [x] **Capacity Explorer:** Dashboard-Prototyp zur Visualisierung der Swarm-Gesamtleistung.

## 🛠️ Schnellstart (Entwickler)

### Voraussetzungen
- Windows mit WSL2 (Ubuntu)
- Python 3.10+
- NVIDIA GPU (RTX 5090 empfohlen für High-Performance Nodes)

### Setup & Inferenz
1. **Repository & Submodule:** `llama.cpp` und `nakshatra` klonen.
2. **Build:** In WSL den Nakshatra-Worker mit `cmake` kompilieren.
3. **Sharding:** Das gewünschte Modell mit `partial_gguf.py` in Layer-Pakete zerlegen.
4. **Start:** Worker-Daemons starten und per `client.py` Prompts abfeuern.

## 📈 Roadmap

- [ ] **Phase 3:** Integration des FastAPI-Gateways & Realtime-Dashboard-Anbindung.
- [ ] **Phase 4:** Multi-Machine Mesh über Tailscale.
- [ ] **Phase 5:** Global Swarm Genesis (Öffentliches Testnetz).

---

**Entwickelt im AAMS-Standard (Autonomous Agentic Managed System).**
