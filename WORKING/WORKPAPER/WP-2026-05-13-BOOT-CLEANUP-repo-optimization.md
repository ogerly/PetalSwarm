# WP-2026-05-13-BOOT-CLEANUP — Repo-Optimierung & Bootstrap

**Datum:** 2026-05-13
**Status:** In Arbeit
**Ziel:** Repository-Größe minimieren, Bootstrap-Prozess automatisieren.

---

## Ausgangslage

- Aktuelle Repo-Größe: ~4.8 GB (durch Shard-Altlasten im Git-Index).
- Struktur: Verschachtelte Repositories erschweren sauberes Committen.
- Abhängigkeiten: `llama.cpp` und `nakshatra` sind externer Code, den wir patchen, aber nicht komplett hosten wollen.

---

## Plan

1. **Patches extrahieren:** 
   - Alle Änderungen an `llama.cpp` in `patches/llama-cpp-nakshatra.patch` sichern.
   - Eigene Nakshatra-Konfigurationen (`cluster_llama31_8b.yaml`) sichern.
2. **Bootstrap-Skript (`setup.sh`):**
   - Automatisiertes Klonen von `llama.cpp` (Commit `c46583b`).
   - Klonen von `nakshatra`.
   - Anwenden der Patches.
   - WSL-Umgebung (venv, dependencies) vorbereiten.
3. **Repository Reset:**
   - `.git` Ordner löschen.
   - `.gitignore` verfeinern (Ausschluss von `llama.cpp/` und `nakshatra/` bis auf die Patches).
   - Neu initialisieren und nach GitHub pushen.

---

## Tasks

- [x] Patches aus `llama.cpp` extrahieren.
- [ ] `setup.sh` (WSL) erstellen.
- [ ] `.gitignore` für "Lean Mode" anpassen.
- [ ] Git-Historie zurücksetzen.
- [ ] Finaler Push nach GitHub.

---

## Definition of Done

- Das GitHub Repository ist < 5 MB groß.
- Ein frischer Clone kann durch `./setup.sh` in WSL komplett wiederhergestellt werden.
- Erster Token-Test (Llama 3.1 8B) läuft weiterhin erfolgreich.
