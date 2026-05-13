# WP-2026-05-13-ARCH-DASH — Dashboard Verdrahtung

**Datum:** 2026-05-13
**Status:** Offen — wartet auf WP-GATE
**Vorgänger:** WP-2026-05-13-ARCH-GATE (Gateway muss laufen)
**Entscheidet:** D-04 (shard-demo.html vs. Vue)

---

## Session Goal

`shard-demo.html` zeigt echte Gateway-Daten statt Fake-Daten.

---

## Panel-zu-Endpunkt Mapping

| Panel | Fake-Daten | Endpunkt |
|---|---|---|
| Mesh Canvas | Hardcoded `roles[]` | `GET /swarm/peers` |
| Live Stats | `jitter()` Zufallswerte | `GET /metrics` |
| Node Load Bars | Zufällige Prozente | `GET /swarm/status` |
| Peer List | Hardcoded `PEERS[]` | `GET /swarm/peers` |
| Chat | `RESPONSES[]` simuliert | `POST /v1/chat/completions` |
| Status Pill | Hardcoded | `GET /health` |

## Tasks

- [ ] Alle Fake-Daten-Stellen identifizieren
- [ ] `dashboard/index.html` erstellen
- [ ] `fetch()` Wrapper mit Error-Handling
- [ ] Gateway-URL konfigurierbar
- [ ] Mindestens 3 Panels verdrahten
- [ ] Chat mit SSE-Streaming
- [ ] Fallback Demo-Modus bei Gateway-Ausfall
- [ ] A-10 beantworten, D-04 entscheiden

## Definition of Done

- [ ] `dashboard/index.html` existiert
- [ ] 3+ Panels mit echten Daten
- [ ] Chat funktioniert gegen Gateway
- [ ] Demo-Modus als Fallback
