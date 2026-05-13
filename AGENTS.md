# AGENTS.md — Globale dezentrale LLM-Inference

> Bridge-Datei für Copilot, Cursor, Claude Code, Codex, Windsurf und alle AGENTS.md-kompatiblen Tools.

## Projektkontext

Dieses Repository baut ein System für globale, dezentrale LLM-Inference auf.
Technische Details: siehe `READ-AGENT.md`.
AAMS-Konventionen: siehe `.agent.json`.

## Regeln für alle Agents

1. **Documentation First** — Kein großer Code ohne Workpaper in `WORKING/WORKPAPER/`.
2. **Hardware-Limits sind hart** — RTX 5090 hat 32 GB VRAM. Nicht überschreiten.
3. **Secrets nie in Code/Docs** — Nur `.env` oder Secret Manager.
4. **AAMS-Workflow folgen** — Session-Start: Workpaper öffnen. Session-Ende: Workpaper schließen, Memory aktualisieren.
5. **Bestehende Docs nicht löschen** — `never_delete` Policy aus `.agent.json`.

## Schnellstart für Agents

```
1. Lies READ-AGENT.md
2. Lies .agent.json
3. Prüfe WORKING/MEMORY/ltm-index.md
4. Öffne oder erstelle Workpaper in WORKING/WORKPAPER/
5. Arbeite. Dokumentiere.
6. Session-Ende: Workpaper schließen → closed/
```

## Verzeichniskonventionen

- `WORKING/WORKPAPER/` — Aktive Session-Dokumente
- `WORKING/WHITEPAPER/` — Stabile Architektur-Wahrheiten
- `WORKING/MEMORY/` — Langzeit-Kontext (ltm-index.md)
- `WORKING/DIARY/` — Zeitlicher Index (wann was geändert)

## Workpaper-Namensformat

`WP-{YYYY-MM-DD}-{TOPIC}-{SUBTOPIC}-{description}.md`

Topics: `ARCH`, `SPEC`, `LTM`, `SEC`, `BOOT`, `FLD`, `RES`, `MKT`, `ISS`, `GOV`, `EDU`
