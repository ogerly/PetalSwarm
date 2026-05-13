# WORKPAPER — Petals + AAMS: verteiltes LLM sichtbar und analysierbar machen

## 0. Ziel dieses Workpapers

Dieses Workpaper beschreibt eine erste lauffähige Example-Implementierung für **Petals** als verteiltes LLM-System. Ziel ist nicht sofort ein Produktivsystem, sondern ein sauber beobachtbarer technischer Proof of Concept.

Der Agent soll:

1. Petals lokal oder in einer privaten Test-Swarm zum Laufen bringen.
2. Einen einfachen Client bauen, der verteilte Inference sichtbar macht.
3. AAMS in das Projekt integrieren.
4. Agentisches Memory ergänzen.
5. Alle Erkenntnisse in Whitepaper/Workpaper/MEMORY dokumentieren.
6. Eine Grundlage schaffen, um später zu entscheiden, ob Petals für eigene dezentrale KI-Infrastruktur sinnvoll ist.

---

## 1. Begriffsklärung

Gemeint ist **Petals**, nicht „Pedals“.

Petals ist ein Open-Source-System für verteilte LLM-Inference und teilweise Fine-Tuning. Die Grundidee ähnelt BitTorrent: Viele Rechner hosten Teile eines großen Modells. Ein Client verbindet sich mit der Swarm und führt Inference über verteilte Modellblöcke aus.

Wichtig: Für sensible Daten soll keine öffentliche Swarm verwendet werden. Für unsere Analyse wird zuerst eine private oder lokale Test-Swarm aufgebaut.

---

## 2. Projektziel

### Primärziel

Eine lauffähige Minimalumgebung, in der sichtbar wird:

* welche Rechner/Peers beteiligt sind,
* welches Modell verwendet wird,
* welche Blöcke verteilt werden,
* wie der Client eine Anfrage stellt,
* wie lange die Inference dauert,
* wo Ausfälle oder Engpässe entstehen,
* wie sich ein agentisches Memory andocken lässt.

### Sekundärziel

Das Projekt soll nach AAMS strukturiert werden, damit jede technische Entscheidung nachvollziehbar bleibt.

---

## 3. Repository-Vorschlag

```txt
petals-aams-example/
├── .agent.json
├── README.md
├── docker-compose.yml
├── .env.example
├── WORKING/
│   ├── WHITEPAPER/
│   │   ├── 000-system-context.md
│   │   ├── 010-petals-architecture.md
│   │   ├── 020-private-swarm.md
│   │   └── 030-agentic-memory.md
│   ├── WORKPAPER/
│   │   ├── 2026-05-13-initial-petals-setup.md
│   │   └── closed/
│   └── MEMORY/
│       ├── ltm-index.md
│       └── decisions.md
├── apps/
│   ├── client/
│   │   ├── README.md
│   │   ├── package.json
│   │   └── src/
│   └── api/
│       ├── README.md
│       ├── requirements.txt
│       └── app.py
├── petals/
│   ├── bootstrap/
│   │   └── README.md
│   ├── server/
│   │   └── README.md
│   └── scripts/
│       ├── run-bootstrap.sh
│       ├── run-server.sh
│       └── run-client-test.py
└── docs/
    ├── diagrams/
    └── observations/
```

---

## 4. AAMS Integration

### 4.1 `.agent.json`

```json
{
  "project": "petals-aams-example",
  "version": "0.1.0",
  "purpose": "Analyse und Visualisierung verteilter LLM-Inference mit Petals",
  "agent_mode": "documentation_first",
  "rules": {
    "document_every_session": true,
    "no_large_code_without_workpaper": true,
    "prefer_private_swarm": true,
    "never_send_sensitive_data_to_public_swarm": true
  },
  "folders": {
    "whitepaper": "WORKING/WHITEPAPER",
    "workpaper": "WORKING/WORKPAPER",
    "memory": "WORKING/MEMORY"
  },
  "technical_focus": [
    "Petals",
    "distributed inference",
    "private swarm",
    "agentic memory",
    "client visualization",
    "LLM infrastructure analysis"
  ]
}
```

---

## 5. Technische Annahmen

### 5.1 Erstes Setup

Für den ersten Proof of Concept gibt es zwei sinnvolle Wege:

| Variante                 | Zweck                                                          | Empfehlung                    |
| ------------------------ | -------------------------------------------------------------- | ----------------------------- |
| Öffentliche Petals-Swarm | Schnell testen, ob Client-Inference grundsätzlich funktioniert | Nur mit neutralen Testprompts |
| Private/local Swarm      | Architektur verstehen, Datenschutz, AAMS-Dokumentation         | Bevorzugt                     |

### 5.2 Entwicklungsumgebung

Empfohlen:

* Linux oder WSL2
* NVIDIA GPU, falls vorhanden
* Python 3.10/3.11 bevorzugt prüfen
* Conda oder venv
* Docker optional
* Node/Vite/Vue für Visual Client

Windows direkt ist zu vermeiden. WSL2 ist realistischer.

---

## 6. Minimaler Petals-Test

### 6.1 Python-Umgebung

```bash
mkdir petals-aams-example
cd petals-aams-example
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install git+https://github.com/bigscience-workshop/petals
pip install transformers torch fastapi uvicorn pydantic
```

Falls CUDA/PyTorch nicht sauber installiert ist, PyTorch separat passend zur lokalen CUDA-Version installieren.

---

## 7. Private Swarm: technische Zielstruktur

```txt
[Bootstrap Peer / DHT]
        |
        | initial_peers
        |
[Petals Server 1] ---- hostet Modellblöcke
[Petals Server 2] ---- hostet Modellblöcke
[Petals Server 3] ---- optional
        |
        |
[Python API Client]
        |
        |
[Vue/Vite Visual Client]
```

---

## 8. Bootstrap Peer

Datei:

```txt
petals/scripts/run-bootstrap.sh
```

Inhalt:

```bash
#!/usr/bin/env bash
set -e

python -m petals.cli.run_dht \
  --host_maddrs /ip4/0.0.0.0/tcp/31337 \
  --identity_path petals/bootstrap/bootstrap1.id
```

Aufgabe des Agenten:

* Script ausführbar machen.
* Ausgabe speichern.
* Die `initial_peers` Adresse extrahieren.
* Adresse in `.env` oder `WORKING/MEMORY/decisions.md` dokumentieren.

---

## 9. Petals Server

Datei:

```txt
petals/scripts/run-server.sh
```

Inhalt:

```bash
#!/usr/bin/env bash
set -e

MODEL_NAME=${MODEL_NAME:-bigscience/bloom-560m}
INITIAL_PEERS=${INITIAL_PEERS:?INITIAL_PEERS fehlt}

python -m petals.cli.run_server "$MODEL_NAME" \
  --initial_peers "$INITIAL_PEERS" \
  --public_name "aams-petals-test-node"
```

Hinweis:

Für erste Tests bewusst ein kleines Modell verwenden. Ziel ist zunächst nicht Modellqualität, sondern Funktionsfähigkeit, Beobachtbarkeit und Architekturverständnis.

---

## 10. Client-Test

Datei:

```txt
petals/scripts/run-client-test.py
```

Inhalt:

```python
import os
import time
from transformers import AutoTokenizer
from petals import AutoDistributedModelForCausalLM

MODEL_NAME = os.getenv("MODEL_NAME", "bigscience/bloom-560m")
INITIAL_PEERS = os.getenv("INITIAL_PEERS", "").split()

if not INITIAL_PEERS:
    raise RuntimeError("INITIAL_PEERS fehlt")

prompt = "Explain distributed inference in one short paragraph:"

started = time.time()

tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoDistributedModelForCausalLM.from_pretrained(
    MODEL_NAME,
    initial_peers=INITIAL_PEERS
)

inputs = tokenizer(prompt, return_tensors="pt")["input_ids"]
outputs = model.generate(inputs, max_new_tokens=80)
text = tokenizer.decode(outputs[0], skip_special_tokens=True)

finished = time.time()

print("MODEL:", MODEL_NAME)
print("INITIAL_PEERS:", INITIAL_PEERS)
print("SECONDS:", round(finished - started, 2))
print("OUTPUT:")
print(text)
```

---

## 11. API-Schicht für Visual Client

Ziel: Der Vue-Client soll nicht direkt Petals ansprechen, sondern eine kleine Python-API.

Datei:

```txt
apps/api/app.py
```

Aufgaben:

* `/health` liefert Status der API.
* `/swarm/config` liefert Modellname, initial peers, runtime mode.
* `/generate` nimmt Prompt entgegen und gibt Antwort plus Metriken zurück.
* `/memory/events` speichert technische Events.
* `/observations` liefert protokollierte Beobachtungen.

Beispiel-Endpunkte:

```txt
GET  /health
GET  /swarm/config
POST /generate
GET  /memory/events
POST /memory/events
```

---

## 12. Visual Client

Technikvorschlag:

* Vue 3
* Vite
* Tailwind
* DaisyUI optional

### UI-Ziel

Der Client soll nicht wie ein normaler Chat aussehen, sondern wie ein Analyse-Dashboard.

Bereiche:

1. **Prompt Panel**

   * Eingabe
   * Start Button
   * max_new_tokens

2. **Response Panel**

   * Modellantwort
   * Laufzeit
   * Tokenanzahl, falls verfügbar

3. **Swarm Panel**

   * Modellname
   * Initial Peers
   * Public/Private Mode
   * Node Count, falls verfügbar

4. **AAMS Panel**

   * aktuelle Session
   * erzeugte Workpaper
   * offene Beobachtungen
   * offene Entscheidungen

5. **Memory Panel**

   * technische Events
   * Fehlermeldungen
   * Messwerte

---

## 13. Agentisches Memory

Für den ersten Schritt reicht ein lokales JSONL/Markdown Memory.

Dateien:

```txt
WORKING/MEMORY/ltm-index.md
WORKING/MEMORY/decisions.md
WORKING/MEMORY/events.jsonl
```

### Event-Format

```json
{
  "timestamp": "2026-05-13T00:00:00Z",
  "type": "inference_test",
  "model": "bigscience/bloom-560m",
  "duration_seconds": 12.4,
  "prompt_chars": 64,
  "result": "success",
  "notes": "First successful private swarm call"
}
```

---

## 14. Whitepaper-Aufgaben

Der Agent soll nach erfolgreichem Setup folgende Whitepaper-Dateien erstellen oder erweitern:

### `000-system-context.md`

Inhalt:

* Warum Petals analysiert wird
* Was verteilte LLM-Inference bedeutet
* Abgrenzung zu Ollama, LM Studio, vLLM, llama.cpp, WebLLM

### `010-petals-architecture.md`

Inhalt:

* Modellblöcke
* DHT / initial peers
* Swarm
* Server
* Client
* Inference-Fluss

### `020-private-swarm.md`

Inhalt:

* Warum private Swarm
* Datenschutz
* Netzwerkanforderungen
* Portfreigaben
* Risiken

### `030-agentic-memory.md`

Inhalt:

* Welche Events gespeichert werden
* Welche Entscheidungen langfristig relevant sind
* Wie AAMS das Projekt stabilisiert

---

## 15. Analysefragen

Der Agent soll während der Umsetzung folgende Fragen beantworten:

1. Läuft Petals aktuell sauber mit der gewählten Python/PyTorch-Version?
2. Funktioniert ein öffentlicher Client-Test?
3. Funktioniert eine private Swarm lokal oder über mehrere Maschinen?
4. Welche Modellgrößen sind realistisch?
5. Wie stabil ist die Verbindung zwischen Peers?
6. Wie verhält sich Petals bei Peer-Ausfall?
7. Welche Daten gehen über das Netzwerk?
8. Wie sinnvoll ist Petals im Vergleich zu lokaler Inference mit Ollama/vLLM?
9. Kann man daraus ein sichtbares dezentrales Demo-System bauen?
10. Wo müsste man Petals patchen oder ergänzen?

---

## 16. Definition of Done

Der erste Arbeitsblock ist fertig, wenn:

* Repository-Struktur angelegt ist.
* `.agent.json` vorhanden ist.
* `WORKING/` Struktur vorhanden ist.
* Petals installierbar ist oder Installationsprobleme dokumentiert sind.
* Ein Client-Test existiert.
* Mindestens ein Inference-Test erfolgreich oder nachvollziehbar fehlgeschlagen ist.
* Ein Vue/Vite-Dashboard Grundgerüst existiert.
* API-Endpunkte für Health, Config und Generate existieren.
* Memory-Events geschrieben werden.
* Die ersten Whitepaper-Dateien angelegt sind.

---

## 17. Arbeitsanweisung an Claude / Coding Agent

```txt
Du arbeitest in diesem Repository als technischer Coding-Agent.

Ziel:
Baue ein lauffähiges Petals-AAMS-Example, mit dem verteilte LLM-Inference sichtbar, testbar und dokumentierbar wird.

Arbeitsregeln:
1. Lies zuerst .agent.json.
2. Lege die WORKING-Struktur an, falls sie fehlt.
3. Schreibe vor jeder größeren Änderung ein Workpaper in WORKING/WORKPAPER/.
4. Ändere nur Dateien, die für den aktuellen Schritt notwendig sind.
5. Dokumentiere jedes technische Ergebnis in WORKING/MEMORY/events.jsonl oder WORKING/MEMORY/decisions.md.
6. Keine sensiblen Prompts an öffentliche Petals-Swarms senden.
7. Bevorzuge private/local Swarm Tests.
8. Wenn Petals wegen Versionen, CUDA, PyTorch oder Netzwerk nicht läuft, dokumentiere exakt den Fehler und schlage den kleinsten nächsten Fix vor.

Erste konkrete Aufgaben:
1. Erzeuge die Repository-Struktur aus dem Workpaper.
2. Erzeuge .agent.json.
3. Erzeuge README.md mit Setup-Anleitung.
4. Erzeuge Python venv Setup-Anleitung.
5. Erzeuge Scripts:
   - petals/scripts/run-bootstrap.sh
   - petals/scripts/run-server.sh
   - petals/scripts/run-client-test.py
6. Erzeuge FastAPI-Grundgerüst in apps/api/app.py.
7. Erzeuge Vue/Vite Client-Grundgerüst in apps/client/.
8. Erzeuge erste Whitepaper-Dateien.
9. Führe keine riesigen Implementierungen auf einmal aus. Arbeite in kleinen, testbaren Schritten.

Wichtig:
Das Ziel ist nicht nur ein Chatbot. Das Ziel ist ein sichtbares Analysewerkzeug für verteilte LLM-Inference mit Petals.
```

---

## 18. Erste manuelle Testsequenz

```bash
# 1. Projekt vorbereiten
cd petals-aams-example
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install git+https://github.com/bigscience-workshop/petals
pip install transformers torch fastapi uvicorn pydantic

# 2. Bootstrap starten
bash petals/scripts/run-bootstrap.sh

# 3. INITIAL_PEERS aus der Bootstrap-Ausgabe kopieren
export INITIAL_PEERS="/ip4/127.0.0.1/tcp/31337/p2p/PEER_ID_HIER"
export MODEL_NAME="bigscience/bloom-560m"

# 4. Server starten
bash petals/scripts/run-server.sh

# 5. Client-Test in zweiter Shell ausführen
source .venv/bin/activate
export INITIAL_PEERS="/ip4/127.0.0.1/tcp/31337/p2p/PEER_ID_HIER"
export MODEL_NAME="bigscience/bloom-560m"
python petals/scripts/run-client-test.py
```

---

## 19. Risiken

| Risiko                                    | Bedeutung                        | Umgang                                     |
| ----------------------------------------- | -------------------------------- | ------------------------------------------ |
| Petals ist älter/teilweise wenig gepflegt | Versionen können brechen         | Erst kleine Tests, Fehler dokumentieren    |
| CUDA/PyTorch Konflikte                    | Installation kann scheitern      | Umgebung exakt festhalten                  |
| Öffentliche Swarm Datenschutz             | Prompts laufen über fremde Nodes | Keine sensiblen Prompts                    |
| Große Modelle brauchen viel VRAM verteilt | Private Swarm evtl. zu klein     | Erst kleines Modell                        |
| Netzwerk/NAT/Ports                        | Peers finden sich evtl. nicht    | Lokal starten, dann LAN, dann Internet     |
| Client suggeriert falsche Kontrolle       | Verteilte Inference ist komplex  | Dashboard muss Metriken und Grenzen zeigen |

---

## 20. Nächster sinnvoller Schritt

Nicht direkt Design bauen.

Zuerst:

1. Repository-Struktur erzeugen.
2. Petals Installation testen.
3. Minimalen Client-Test ausführen.
4. Fehler sauber ins Workpaper schreiben.
5. Danach API und Vue-Dashboard bauen.

Dieses Projekt ist primär eine Architektur- und Analysebasis für dezentrale KI-Infrastruktur.
