# WP-2026-05-13-ARCH-GATE — FastAPI Gateway

**Datum:** 2026-05-13
**Status:** Offen — wartet auf WP-BOOT
**Vorgänger:** WP-2026-05-13-ARCH-BOOT (Petals-Server muss laufen)
**Referenz:** WH-001-ARCH-system-architektur.md (Sektion 5)

---

## Session Goal

FastAPI-Gateway läuft auf Port 8000, `/health` und `/swarm/status` antworten korrekt,
`/v1/chat/completions` leitet Anfragen an den Petals-Server weiter.

---

## Tasks

### Phase 1 — Grundgerüst
- [ ] `gateway/` Verzeichnis anlegen
- [ ] `gateway/requirements.txt` erstellen (fastapi, uvicorn, petals, pydantic)
- [ ] `gateway/app.py` mit Grundstruktur
- [ ] `GET /health` → Gateway-Status + Swarm-Verbindungsprüfung
- [ ] `GET /swarm/status` → aktive Nodes, Blöcke, VRAM je Peer
- [ ] `GET /swarm/peers` → Peer-Liste
- [ ] CORS konfigurieren (Dashboard braucht Cross-Origin-Zugriff)

### Phase 2 — OpenAI-Kompatibilität
- [ ] `POST /v1/chat/completions` → Inference, streaming
- [ ] `GET /v1/models` → Liste verfügbarer Modelle
- [ ] Request/Response-Format exakt wie OpenAI API
- [ ] Streaming mit Server-Sent Events (SSE)

### Phase 3 — Observability
- [ ] `GET /metrics` → Prometheus-Format (tok/s, Latenz, Fehlerrate)
- [ ] `GET /memory/events` → Letzte N Events aus events.jsonl
- [ ] `POST /memory/events` → Event schreiben

---

## API-Endpunkte (Zielzustand)

```
GET  /health                   → { status, swarm_connected, nodes, uptime }
GET  /v1/models                → { data: [{ id, object, owned_by }] }
POST /v1/chat/completions      → OpenAI-kompatibel, streaming
GET  /swarm/status             → { nodes, total_blocks, total_vram_gb }
GET  /swarm/peers              → [{ peer_id, blocks, vram_gb, latency_ms }]
GET  /metrics                  → Prometheus text format
GET  /memory/events            → [{ timestamp, type, result, ... }]
POST /memory/events            → { timestamp, type, result, ... }
```

---

## Definition of Done

- [ ] Gateway startet mit `uvicorn gateway.app:app --port 8000`
- [ ] `/health` antwortet mit korrektem Status
- [ ] `/swarm/status` zeigt echte Swarm-Daten
- [ ] `/v1/chat/completions` liefert OpenAI-kompatible Antwort
- [ ] CORS erlaubt Zugriff von `localhost:3000`
- [ ] Alle Endpunkte in diesem Workpaper dokumentiert

---

## File Protocol

| Aktion | Datei | Grund |
|---|---|---|

*Wird während der Session gefüllt.*

---

## Ergebnisse

*Wird während der Session gefüllt.*
