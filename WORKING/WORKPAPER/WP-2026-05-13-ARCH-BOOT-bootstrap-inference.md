# WP-2026-05-13-ARCH-BOOT — Bootstrap Peer + First Inference

**Datum:** 2026-05-13
**Status:** Offen — wartet auf WP-ENV
**Vorgänger:** WP-2026-05-13-ARCH-ENV (Conda + Petals müssen laufen)
**Referenz:** WH-001-ARCH-system-architektur.md (Sektionen 5, 6)

---

## Session Goal

Petals-Server läuft auf dem RTX 5090, ein Modell ist geladen, der erste Inference-Test ist erfolgreich.

---

## Tasks

### Bootstrap Peer
- [ ] Bootstrap-Peer starten: `python -m petals.cli.run_dht --host_maddrs /ip4/0.0.0.0/tcp/31337`
- [ ] Peer-ID sichern und in `events.jsonl` loggen
- [ ] Erreichbarkeit lokal testen

### Server starten
- [ ] Petals-Server mit gewähltem Modell (D-02) starten
- [ ] `--num_blocks` und `--initial_peers` konfigurieren
- [ ] VRAM-Verbrauch messen und dokumentieren
- [ ] Server-Stabilität 5 Minuten beobachten

### First Inference
- [ ] Python-Client-Skript schreiben: `infra/scripts/test-client.py`
- [ ] Prompt senden, Antwort empfangen
- [ ] tok/s messen
- [ ] Ergebnis in `events.jsonl` loggen

---

## Infrastruktur-Dateien erstellen

- [ ] `infra/bootstrap/run-bootstrap.sh`
- [ ] `infra/server/run-server.sh`
- [ ] `infra/scripts/test-client.py`
- [ ] `.env.example` mit Bootstrap-Konfiguration

---

## Zu beantworten

- **A-03:** Wie viele tok/s erreicht der Swarm als Single-Node?
- **A-05:** Was geht tatsächlich über das Netzwerk?

---

## Definition of Done

- [ ] Bootstrap-Peer läuft, Peer-ID gesichert
- [ ] Server mit Modell gestartet, VRAM-Verbrauch dokumentiert
- [ ] Mindestens ein erfolgreicher Inference-Test
- [ ] tok/s gemessen
- [ ] `test-client.py` funktioniert reproduzierbar
- [ ] Alle Events in `events.jsonl`

---

## File Protocol

| Aktion | Datei | Grund |
|---|---|---|

*Wird während der Session gefüllt.*

---

## Ergebnisse

*Wird während der Session gefüllt.*
