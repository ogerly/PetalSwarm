# WP-2026-05-13-ARCH-SCALE — Llama 70B + WAN Peers

**Datum:** 2026-05-13
**Status:** Offen — wartet auf WP-DASH (Phase 1 Abschluss)
**Vorgänger:** Alle Phase-1-Workpapers
**Referenz:** WH-001 Sektionen 4, 6
**Entscheidet:** D-03 (Tailscale vs. Port-Forward), D-05 (Laptop-Rolle)

---

## Session Goal

Llama 3.1 70B Q3_K_S auf RTX 5090 testen. Ersten externen Peer anbinden.

---

## Tasks

### Modell-Upgrade
- [ ] Llama 3.1 70B Q3_K_S auf 5090 laden
- [ ] VRAM-Verbrauch messen (erwartet: ~28 GB)
- [ ] tok/s als Single-Node messen
- [ ] Stabilität testen (10+ Minuten Dauerlast)

### WAN-Peers
- [ ] Tailscale installieren + Mesh konfigurieren
- [ ] Bootstrap-Peer über Tailscale erreichbar machen
- [ ] Ersten externen Peer einladen
- [ ] tok/s mit zweitem Peer messen
- [ ] `docs/joining-the-swarm.md` für externe Peers

### Analyse
- [ ] A-02: Blöcke bei Q3_K_S?
- [ ] A-04: tok/s-Änderung mit Peer?
- [ ] A-06: Peer-Ausfall-Verhalten?
- [ ] A-08: Tailscale-Stabilität?
- [ ] A-09: Upload als Flaschenhals?

## Definition of Done

- [ ] 70B läuft auf 5090 (oder Fallback dokumentiert)
- [ ] Mindestens 1 externer Peer verbunden
- [ ] tok/s Single vs. Multi-Node verglichen
- [ ] D-03 und D-05 entschieden
- [ ] `joining-the-swarm.md` geschrieben
