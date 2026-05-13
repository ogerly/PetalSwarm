# READ-AGENT.md — Globale dezentrale LLM-Inference

> **Letzte Aktualisierung:** 2026-05-13
> **AAMS Contract:** AAMS/2.0
> **Projekt:** dezentrale-inference-global (Verzeichnis: web-petals)

---

## Projektübersicht

Dieses Projekt baut ein System für **globale, dezentrale LLM-Inference** auf — sichtbar, messbar, und offen.

**Kernprinzip:** Jeder mit einer GPU kann beitreten. Jeder mit einem Browser kann anfragen. Kein einzelner Punkt kontrolliert das System.

### Technologie-Stack

| Komponente | Technologie | Status |
|---|---|---|
| Inference-Protokoll | Petals (Pipeline-Parallelismus, DHT) | Geplant |
| Primäre Hardware | NVIDIA RTX 5090 (32 GB GDDR7) | Verfügbar |
| Gateway | FastAPI (OpenAI-kompatibel) | Geplant |
| Dashboard | `shard-demo.html` → Vue 3 (Phase 2) | UI-Prototyp vorhanden |
| Netzwerk | Tailscale (Phase 1) → Port-Forward/VPS (Phase 2) | Geplant |
| Dokumentation | AAMS/2.0 | ✅ Aktiv |

### Modelle

- **Phase 1 (PoC):** `bigscience/bloom-560m` oder `meta-llama/Llama-3.2-3B`
- **Phase 2 (Ziel):** `meta-llama/Meta-Llama-3.1-70B-Instruct` (Q3_K_S, ~28 GB)

---

## Verzeichnisstruktur

```
web-petals/
├── .agent.json              AAMS/2.0 Manifest
├── READ-AGENT.md            ← dieses Dokument
├── AGENTS.md                Bridge für Copilot/Cursor/Claude
├── .gitignore
│
├── shard-demo.html          Visual Dashboard (Standalone-Prototyp)
├── WORKPAPER-*.md           Hauptplanungsdokument (Root-Level)
│
├── WORKING/                 AAMS Workspace
│   ├── WHITEPAPER/          Stabile Architektur-Dokumente
│   ├── WORKPAPER/           Aktive Session-Dokumente
│   │   ├── closed/          Abgeschlossene Workpapers
│   │   └── observe/         Beobachtungs-Workpapers
│   ├── MEMORY/              Langzeit-Kontext
│   ├── AGENT-MEMORY/        LTM Store
│   ├── DIARY/               Zeitlicher Index
│   ├── LOGS/                Laufzeit-Logs
│   ├── GUIDELINES/          Projekt-Richtlinien
│   └── TOOLS/               Lokale Skills/Skripte
│
└── .archive/                Veraltete Dokumente
```

---

## Für Agents: Einstiegspunkte

1. **Erst lesen:** Dieses Dokument
2. **Dann:** `.agent.json` für AAMS-Konventionen
3. **Kontext:** `WORKING/MEMORY/ltm-index.md` für bisherige Entscheidungen
4. **Aktuelles Workpaper:** `WORKING/WORKPAPER/` für offene Session
5. **Planung:** `WORKPAPER-Globale-dezentrale-LLM-Inference.md` für Gesamtarchitektur

---

## Regeln

- `documentation_first`: Kein großer Code ohne Workpaper
- `prefer_private_swarm_for_testing`: Erst privat testen
- `never_send_sensitive_data_to_public_swarm`
- `hardware_constraints_are_hard_limits`: 32 GB VRAM ist die Obergrenze
- Secrets nur in `.env`, nie in Dokumenten

---

## Offene Entscheidungen

| # | Frage | Status |
|---|---|---|
| D-01 | CUDA-Version: 12.1 vs. 12.6 für RTX 5090 | Offen |
| D-02 | Erstes Testmodell: bloom-560m vs. Llama 3.2 3B | Offen |
| D-03 | Bootstrap-Zugang: Tailscale vs. Port-Forward | Offen |
| D-04 | Dashboard-Start: shard-demo.html vs. sofort Vue | Offen |
| D-05 | Laptop-Rolle: nur Client vs. Embedding-Layer | Offen (vermutlich nur Client) |

---

*Generiert durch AAMS on_first_entry am 2026-05-13.*
