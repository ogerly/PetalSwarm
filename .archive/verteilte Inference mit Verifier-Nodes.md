Shard: Browser-basiert (WebGPU), verteilte Inference mit Verifier-Nodes.

Das Demo zeigt alles Wesentliche von Shard in einem File:

Animiertes P2P-Mesh – Nodes (Scout/Shard/Leech) bewegen sich und verbinden sich live via Canvas
Pipeline-Diagramm – Leech → Scout → Shard → Stream, mit animiertem Datenstrom
Chat-Interface – simuliert den echten Ablauf: Scout drafting → Shard verifying → Token-Streaming, mit Accept Rate und tok/s in den Metadaten
API-Snippet – zeigt den OpenAI-kompatiblen Drop-in direkt
Live-Stats-Sidebar – Nodes, TPS, GPU-Ersparnis, Peer-Liste mit Shard-Guthaben, alles live ticking
Kostenvergleich – Cloud vs. Shard ($0.000)

>>>>>>>>>>>>>>>>>>>>>>
verbunden mit  <https://github.com/bigscience-workshop/petals#connect-your-gpu-and-increase-petals-capacity> ??

16:50
Claude hat geantwortet: Nein — keine direkte Verbindung.

Analysierte Verbindungen zwischen zwei verteilten Inferenz-Projekten
Analysierte Verbindungen zwischen zwei verteilten Inferenz-Projekten
Nein — keine direkte Verbindung. Shard und Petals sind vollständig unabhängige Projekte. Aber die Idee ist verwandt, die Umsetzung grundlegend anders:

Shard vs. Petals — der Vergleich
Petals Shard
Org BigScience / HuggingFace (akademisch) TrentPierce (unabhängig)
Ansatz Pipeline-Parallelismus Spekulatives Dekodieren
Wie verteilt? Jeder Node hostet ein paar Layer des großen Modells (z. B. Llama 405B aufgeteilt) Scouts draften Tokens, Shards verifizieren parallel
Compute-Quelle Nvidia-GPUs (conda/pip, CUDA) Browser via WebGPU (Scout) + Desktop/BitNet (Shard)
Sprache Python / PyTorch / HuggingFace Transformers Rust (libp2p) + TypeScript/React + WebLLM
Modelle Llama 3.1 405B, Mixtral, Falcon, BLOOM BitNet b1.58 (1.58-bit ternär, sehr klein)
Einstieg pip install petals → GPU nötig Browser-Tab öffnen → kein Setup
Lizenz MIT BUSL-1.1
GitHub Stars ~9.9k (etabliert, seit 2022) 1 (neu, Feb 2026)
Aktiv? Letztes Release Sep 2023 – eher ruhig Aktiv (v0.4.9, Feb 2026)
Der konzeptuelle Unterschied
Petals: Das Modell selbst ist verteilt — Node A hält Layer 1–20, Node B hält Layer 21–40 usw. Jede Anfrage wandert durch alle Nodes sequenziell.

Shard: Das Modell läuft vollständig auf dem Shard-Node (BitNet), aber Scouts im Browser raten vorab viele Tokens mit einem winzigen Modell. Der Shard verifiziert nur noch — deutlich weniger Arbeit als von Null generieren.

Was man kombinieren könnte (theoretisch)
Petals' Pipeline-Parallelismus + Shards spekulatives Drafting wären komplementär — aber das ist kein Plan der Projekte, sondern reine Spekulation. Kein gemeinsamer Code, keine Abhängigkeiten, keine Verbindung in den READMEs.

>>>>>>>>>>>>>>>>>>>>>>>>>>>

tpierce89 Vor 85 Tagen | nächste [–]

Hallo HN! Ich habe Shard entwickelt, ein browsergestütztes verteiltes KI-Inferenznetzwerk, das es Benutzern ermöglicht, Rechenleistung (über WebGPU) beizusteuern, während leistungsstarke Verifizierungsknoten die Ausgaben finalisieren.
Was es gerade ist

Shard ist ein funktionierendes Frühphasensystem, das Folgendes ermöglicht: • Browser fungieren als Scout-Knoten, um WebGPU-Berechnungen beizusteuern • Ein libp2p-Mesh für P2P-Netzwerke • Verifizierungsknoten führen stärkere lokale Modelle aus, um Schlussfolgerungen zu validieren und abzuschließen • Eine Demo-Web-App, die Sie noch heute live ausprobieren können • Clients greifen problemlos zurück, wenn WebGPU nicht verfügbar ist • Rust-Daemon + Python-API + Web-Benutzeroberfläche, alles miteinander verkabelt

Im Wesentlichen handelt es sich dabei um ein gemeinsames Inferenzgefüge —denken Sie an verteilte GPUs von Freiwilligen’, Browser + stärkere Hosts, die Ergebnisse in zuverlässige Antworten umwandeln. Das Repo enthält Tools und Builds für Desktop-, Web- und Daemon-Komponenten.

Warum es wichtig ist

Es besteht eine wachsende Kluft zwischen massiven Modellen und zugänglicher Rechenleistung. Shard zielt darauf ab: • Nutzen Sie ungenutzte WebGPUs in Browsern (Scouts) • Ergebnisse auf robusten Verifizierungsknoten validieren und “beenden” • Ermöglichen Sie dezentrale Inferenz ohne zentralisierte Cloud-Kosten • Erkunden Sie Community-gesteuerte Rechennetzwerke für KI-Aufgaben

Dies ist nicht nur eine Demo — es ist ein Full-Stack-P2P-Inferenzsystem mit Transport-, Netzwerk- und Workflow-Management.

Aktuelle Einschränkungen • Frühstadium, nicht produktionsgehärtet • Benötigt mehr Tests, Dokumentation und Beispiele • Sicherheits- und Anreizebenen sind zukünftige Arbeit • UX rund um das Zusammenführen von Scheduler/Mesh könnte verbessert werden

Komm und bau mit mir

Wenn Sie sich für dezentrale Berechnungen, KI-Infrastruktur, Web-GPU oder Mesh-Netzwerke interessieren — würde ich mich über Feedback, Beiträge und Ideen freuen. Lassen Sie uns darüber sprechen, wohin gemeinsame Inferenznetzwerke als nächstes gehen könnten.

Repo: <https://github.com/TrentPierce/Shard>

Verdverm Vor 85 Tagen <span class="age" title="2026-02-17T01:51:30 1771293090"><a href="item?id=47042730"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;">Vor 85 Tagen</font></font></a></span> | Vorgeschichte [–]

Wenn Sie dies mit Ai so einfach tun können, warum möchte ich dann Ihres anstelle des von meinem Ai generierten verwenden?

tpierce89 Vor 84 Tagen | Elternteil [–]

Bei Shard geht es nicht um die Generierung von Inhalten, sondern um die Infrastruktur für verteilte KI-Berechnungen. Anstatt Cloud-Anbieter für GPU-Zeit zu bezahlen, können Sie auf freie WebGPU-Kapazität von Browsern + Verifizierungsknoten zugreifen. Betrachten Sie es als gemeinsam genutzte Computerressourcen und nicht als KI-Assistenten. Der Assistent ist nur eine Möglichkeit zu zeigen, dass verteilte Inferenz funktioniert. Ich habe auch vor, Zugriff auf die API hinzuzufügen.

Verdverm Vor 84 Tagen <span class="age" title="2026-02-17T16:21:58 1771345318"><a href="item?id=47049213"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;">Vor 84 Tagen</font></font></a></span> | Wurzel | Elternteil [–]

Sie haben Ai verwendet, um den Code für dieses Projekt zu generieren, ja?
Warum lasse ich nicht stattdessen meinen Ai den gleichen Code generieren?

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
bitte dieses projket komplett analysieren. <https://github.com/TrentPierce/Shard>
die idee, die umsetzung. hart nachdenken wie das sinnvoll funktionieren kann. als beispiel könnte man die idee des  pirat bay systems herannehmen.
das verteilen von  grossen files. LLM modellen. ZIEL : herausfinden wie wir grosse frontier modelle verteilt dezentral nutzen können. ziel ist erstmal ein kleineres modell was um die 50 - 70 B Parameter hat und mehr als 32 GB VRAM belegen würde .

>>>
antwort Grok:
Die Analyse des Shard-Projekts von Trent Pierce vor dem Hintergrund deiner Ziele – ein großes KI-Modell (50-70B Parameter, >32 GB VRAM) dezentral zu verteilen – zeigt eine interessante, aber in der aktuellen Form ungeeignete Lösung. Ich konzentriere mich auf die Kernmechanik und das Muster, nicht auf unwichtige Details.

### 🧠 Kernidee & Architektur von Shard

Shard ist **kein** Datei- oder Modellverteilsystem wie BitTorrent oder The Pirate Bay. Es ist ein **"Speculative Inference Accelerator"**.

* **Grundprinzip**: Ein großes, teures LLM (das "starke" Modell auf einer teuren GPU) wird nur zur Validierung genutzt. Ein kleineres, günstigeres Modell (auf "idle edge compute") erzeugt spekulativ Tokens.
* **Arbeitsablauf**: Das kleine Modell generiert preiswert einen Entwurf. Das große Modell prüft diesen Entwurf blockweise. Nur bei Abweichungen wird das große Modell zur Korrektur genutzt.
* **Architektur-Fokus**: Routing von **Rechenaufgaben** (Inferenzschritte), nicht von Datei-Chunks. Output ist ein "Receipt" (Quittung) mit Metadaten, kein Modell-File.

### ⚠️ Kritische Lücke: Das Pirate-Bay-Analogon funktioniert hier nicht

Deine Analogie zu The Pirate Bay ist für das **Verteilen der Modell-Datei** passend, für die **Inferenz** aber unzutreffend. Der entscheidende Unterschied liegt im Verhältnis von Rechenlast zu Datenmenge:

| **Konzept** | **Verteilen von Dateien (z. B. .torrent)** | **Dezentrale Inferenz von LLMs** |
| :--- | :--- | :--- |
| **Kernaktion** | Viele Nodes senden **statische Daten-Chunks** an einen Peer. | Viele Nodes führen **komplexe Berechnungen** mit einem Teil des Modells aus. |
| **Datenmenge vs. Rechenlast** | Hohe Datenmenge, aber die Berechnung (Hashing) ist trivial. | Die Software/Datenmenge ist zwar groß (>32GB), aber die eigentliche Rechenlast (Matrix-Multiplikationen) ist immens hoch. |
| **Netzwerkanforderung** | Asymmetrisch: Upload-Bandbreite der Seeder ist entscheidend. | Symmetrisch & latenzkritisch: Ergebnisse müssen schnell aggregiert werden, sonst ist die Inferenz langsam. |

**Fazit**: Das BitTorrent-Protokoll ist perfekt, um die >32 GB große Modell-Datei an viele Nodes zu **verteilen**. Es ist aber völlig ungeeignet, um die Laufzeit-Inferenz zu koordinieren. Shard versucht Letzteres, allerdings mit einer spekulativen Methode und nicht mit Tensor-Parallelität.

### 💡 Wie ein System für 50-70B-Modelle sinnvoll funktionieren *könnte*

Um ein Modell dieser Größe dezentral zu nutzen, muss man das Problem in zwei Teile zerlegen. Das interessante Muster aus deiner Fragestellung kombiniert beide:

1. **Modell-Verteilung (Das "Pirate Bay"-Muster)**:
    * **Problem**: Wie bekommt man die >32 GB große Modell-Datei effizient auf viele Nodes?
    * **Lösung**: BitTorrent oder IPFS. Jeder Node, der mitmachen will, lädt die Datei chunkweise von anderen Nodes herunter (und teilt sie gleichzeitig). Das ist extrem effizient und der Standard für große Dateien.

2. **Dezentrale Inferenz (Das muss anders sein als Shard)**:
    * **Problem**: Kein einzelner Node hat genug VRAM für das gesamte Modell.
    * **Lösung**: Das Modell muss über mehrere Nodes **aufgeteilt** werden. Das erfordert **Tensor-Parallelität** oder **Pipeline-Parallelität**, nicht Shards spekulativen Ansatz.
    * **Notwendigkeit**: Dafür braucht man eine extrem schnelle, latenzarme Netzwerkverbindung (z. B. 10Gbit/s oder schneller) zwischen den Nodes, die gemeinsam einen Inferenzschritt ausführen. Über das öffentliche Internet ist das derzeit für interaktive Anwendungen viel zu langsam.

### 💎 Zusammenfassung & konkrete Schritte

Deine Suche nach einem dezentralen System für große Modelle ist absolut nachvollziehbar, aber Shard in seiner jetzigen Form ist eine **Inferenz-Beschleunigungstechnik**, keine Verteilungs-Technologie.

Das sinnvollste Vorgehen für dein Ziel ist eine **hybride Architektur, die beide Muster kombiniert**:

1. **Verteilung der Modell-Datei**: Nutze **BitTorrent/IPFS**, um das große Modell schnell an alle teilnehmenden Nodes zu verteilen. Dieses Muster ist gelöst.
2. **Inferenz**: Wenn das Modell auf einen Node passt (weil du z. B. einen leistungsstarken "Super-Node" hast), kann Shards spekulative Methode helfen, Kosten zu sparen. Wenn das Modell verteilt werden *muss* (Tensor-Parallelität), brauchst du eine andere Software wie **Petals** oder **exo**, die für Hochgeschwindigkeitsnetzwerke zwischen den Nodes konzipiert sind.
3. **Kombination**: Ein System könnte so aussehen: Petals-Nodes holen sich die Modell-Shards via BitTorrent und führen dann gemeinsam die Inferenz über ein schnelles Backbone-Netzwerk aus.

Ist dein primäres Ziel, die Datei effizient zu verteilen, oder die teure Inferenzarbeit auf günstigerer Hardware auszuführen? Je nach Schwerpunkt würde ich eine andere Architektur empfehlen.

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.
das verteilen ist eher standart. das hauptziel ist schon  die teure Inferenzarbeit auf günstigerer Hardware auszuführen ..

>>>>

Verstanden. Wenn das Kernziel die **Verlagerung teurer Inferenzarbeit auf günstigere, dezentrale Hardware** ist, dann müssen wir uns von der reinen Dateiverteilung lösen und genau analysieren, wie man die Rechenlast eines 50-70B-Modells auf Knoten mit begrenzter VRAM aufteilen kann.

Hier ist der aktuelle Stand der Technik und wie ein sinnvolles System dafür aussehen müsste – mit Shard als einem interessanten, aber unvollständigen Puzzleteil.

### Das fundamentale Problem: Speicher vs. Berechnung

Ein 70B-Parameter-Modell (z.B. Llama 3.3 70B) benötigt etwa 140 GB Speicher in FP16. Die Herausforderung ist nicht die reine Rechenleistung (viele Consumer-GPUs wären schnell genug), sondern die **Speicherwand (Memory Wall)**. Die Inferenzarbeit auf günstigere Hardware zu verlagern, bedeutet, diese Speicherwand zu überwinden.

Es gibt drei grundlegende Methoden, dies zu tun, und jede hat spezifische Anforderungen an die Knoten und das Netzwerk:

| Methode | Wie es funktioniert | Hardware-Anforderung pro Knoten | Netzwerk-Anforderung | Realistisch für "günstige Hardware" über Internet? |
| :--- | :--- | :--- | :--- | :--- |
| **1. Tensor-Parallelität** | Das Modell wird Schicht-übergreifend in vertikale Scheiben zerlegt. Jeder Knoten berechnet einen Teil **jeder einzelnen** Matrix-Multiplikation. | Jeder Knoten braucht dennoch fast den vollen Speicher für die Gewichte seines "Shards" oder zumindest einen sehr großen Teil. | Extrem hoch: Benötigt Hochgeschwindigkeits-Verbindungen (NVLink, InfiniBand) mit sehr niedriger Latenz, da bei jedem Schritt Ergebnisse synchronisiert werden müssen. | **Nein.** Untauglich für lose gekoppelte Consumer-Hardware über WAN. |
| **2. Pipeline-Parallelität** | Das Modell wird in **horizontale Schichtgruppen** (Stages) zerlegt, z.B. die ersten 20 Schichten auf Knoten A, die nächsten 20 auf Knoten B usw. Ein Mikro-Batch durchläuft die Pipeline. | Jeder Knoten muss nur die ihm zugewiesenen Schichten in den VRAM laden können. Eine RTX 3090 (24 GB VRAM) könnte problemlos 15-20 Schichten eines 70B-Modells halten. | Moderat: Es muss nur der Aktivierungstensor (die Zwischenergebnisse) zwischen den Stages gesendet werden. Das sind bei 70B-Modellen einige Megabyte pro Schritt. | **Ja!** Die Datenmenge pro Schritt ist überschaubar, und Latenz ist weniger kritisch als Durchsatz. |
| **3. Hybride Expert-Modelle (MoE)** | Nur ein Teil des Modells ("Experten") wird für eine bestimmte Eingabe aktiviert. Die Last kann auf Knoten mit unterschiedlichen Experten verteilt werden. | Ein Knoten kann einen oder mehrere Experten beherbergen. Der Speicherbedarf ist viel geringer als beim Gesamtmodell. | Moderat bis hoch: Routing-Entscheidungen und Aktivierungen müssen gesendet werden. | **Ja, mit Einschränkungen.** Dies setzt aber voraus, dass das Modell speziell als MoE trainiert wurde. |

**Fazit**: Für dein Ziel, ein **bestehendes** 50-70B-Modell (das sehr wahrscheinlich ein dichtes Modell und kein MoE ist) auf günstiger, verteilter Hardware auszuführen, ist **Pipeline-Parallelität die einzig gangbare Methode**.

### Bestehende Lösungen und wie Shard dazu passt

Es gibt bereits Projekte, die genau dies mit Pipeline-Parallelität umsetzen. Shard verfolgt einen anderen, komplementären Ansatz.

* **Petals & exo**: Dies sind die führenden Open-Source-Projekte für dezentrale Inferenz.
  * **Wie es funktioniert**: Sie implementieren verteilte Pipeline-Parallelität. Ein "Supervisor"-Node teilt die Modellschichten auf die verfügbaren "Worker"-Nodes auf. Deine Anfrage durchläuft dann die Pipeline der Worker und die Antwort wird zurückgesendet. exo ist bekannt für seine Fähigkeit, Modelle dynamisch auf heterogener Hardware (z.B. einem Mix aus MacBooks und Nvidia-GPUs) zu verteilen.
  * **Limitierung**: Die Gesamt-Inferenzzeit wird durch den langsamsten Knoten und die Netzwerklatenz zwischen den Stages bestimmt. Es eignet sich daher eher für Batch-Verarbeitung oder weniger latenzkritische Aufgaben.

* **Shard (als ergänzendes Muster)**: Shard verfolgt keine Pipeline-Parallelität, sondern **"Speculative Inference"**. Dies ist eine vielversprechende, aber andere Idee für einen **lokalen Cluster**:
  * **Idee**: Shard läuft bei dir im LAN oder sogar auf derselben Maschine. Ein **kleines "Draft"-Modell** (z.B. Llama 3.2 3B), das in den VRAM deiner "Edge"-GPU passt, macht die Hauptarbeit und generiert spekulativ Tokens. Ein leistungsstärkerer Knoten (deine "Supervisor"-GPU, die das große 70B-Modell hostet) überprüft diese Tokens nur noch in größeren Blöcken.
  * **Kosteneinsparung**: Deine teure, große GPU wird nur noch für den Verifikationsschritt genutzt und ist die meiste Zeit inaktiv, während die billige Edge-GPU läuft. Das spart Energie und reduziert die Auslastung der teuren Hardware.
  * **Limitierung**: Das **große Modell muss dennoch vollständig auf *einen* leistungsstarken Knoten passen**. Shard verteilt das große Modell selbst nicht; es reduziert nur dessen Nutzung. Für dein 50-70B-Modell bräuchtest du also weiterhin einen Knoten mit >140 GB VRAM (z.B. mehrere A100 oder H100).

### Konkrete Handlungsoptionen für dein Projekt

Aus dieser Analyse ergeben sich für dich zwei klare, unterschiedliche Wege:

1. **Weg A: Das große Modell muss wirklich verteilt werden (Ziel: Nutzung günstiger Consumer-Hardware über das Internet)**
    * **Methode**: Setze auf **Petals oder exo** mit Pipeline-Parallelität.
    * **Vorgehen**: Experimentiere mit einem 70B-Modell (z.B. Llama 3.3 70B) und exo. Verbinde zwei Rechner mit je einer RTX 3090/4090 (24 GB VRAM) über ein schnelles LAN. Konfiguriere exo so, dass es die Modell-Layer automatisch aufteilt (ca. 35-40 Layer pro Karte). Analysiere die erreichbaren Tokens pro Sekunde und die Latenz. Das wird die Machbarkeit für einen WAN-Test zeigen. Shard wäre hier irrelevant.

2. **Weg B: Du hast bereits einen sehr starken Knoten und willst dessen Nutzung optimieren (Ziel: Auslastung der teuren GPU senken, Edge-Hardware einbinden)**
    * **Methode**: Nutze das **Shard-Prinzip der Speculative Inference** weiter.
    * **Vorgehen**: Dies ist ein lokaler Cluster-Ansatz. Stelle sicher, dass dein Supervisor-Knoten das gesamte 70B-Modell in seinen VRAM-Verbund (z.B. 4x A100) laden kann. Auf den Edge-Knoten läuft ein deutlich kleineres Modell (z.B. Llama 8B) und der Shard-Verifier. Der Engpass ist hier nicht die Inferenz, sondern die Speicherbandbreite zwischen Draft- und Verifikationsmodell.

**Zusammenfassend**: Shard ist ein kluger Ansatz, um die Auslastung teurer Hardware zu senken, löst aber **nicht** das Problem, ein großes Modell auf viele kleine Hardware-Knoten zu verteilen. Für dein formuliertes Hauptziel ist **Pipeline-Parallelität via exo oder Petals der technisch korrekte und einzig sinnvolle Weg**. Ich empfehle, mit einem exo-Setup im LAN zu starten.

Welcher der beiden Wege entspricht eher deiner verfügbaren Hardware und deinem Anwendungsszenario?

>>>>>>>>>>>>>>>>>>>>>>>>>>
<https://github.com/ogerly/exo> <https://github.com/bigscience-workshop/petalseine> anylse der beiden tools zu dem thema

>
<https://github.com/ogerly/exo> <https://github.com/bigscience-workshop/petalseine> anylse der beiden tools zu dem thema

>>>>>>>>>>>>>>>>>>>>>
Petals ist das interesannte tool für mich. ich werde es mal aufsetzen und schauen wie der stand ist.

>>>>>>>>>>>>>>>>>>>>>>>>>>>>

Petals ist das interesannte tool für mich. ich werde es mal aufsetzen und schauen wie der stand ist.

Thought for 3s

Super, Petals ist eine starke Wahl für dein Ziel!  Hier ist eine aktuelle und praxisnahe Installations- & Test-Anleitung (Stand Mai 2026):1. Schnellstart – Testen ohne eigenen großen ServerEinfachster Weg: Google Colab (empfohlen zum ersten Ausprobieren)Öffne dieses offizielle Tutorial:
<https://colab.research.google.com/drive/1uCphNY7gfAUkdDrTx21dZZwCOUDCMPw8>
Runtime → Change runtime type → GPU (T4 reicht zum Testen)
Die Zellen ausführen und direkt mit großen Modellen (z. B. Llama 3.1 405B) chatten.

1. Lokale Installation (Linux / NVIDIA GPU empfohlen)bash

# 1. Conda-Umgebung (sehr empfohlen)

conda create -n petals python=3.10
conda activate petals

# 2. PyTorch mit CUDA installieren

conda install pytorch pytorch-cuda=12.1 -c pytorch -c nvidia

# 3. Petals installieren

pip install git+<https://github.com/bigscience-workshop/petals>

1. Als Client nutzen (Inference)python

from transformers import AutoTokenizer
from petals import AutoDistributedModelForCausalLM

model_name = "meta-llama/Meta-Llama-3.1-405B-Instruct"   # oder ein kleineres Modell

tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoDistributedModelForCausalLM.from_pretrained(model_name)

inputs = tokenizer["Die Zukunft der dezentralen KI ist", return_tensors="pt"]("input_ids")
outputs = model.generate(inputs, max_new_tokens=100, temperature=0.7)
print(tokenizer.decode(outputs[0]))

1. Als Server beitreten (deine GPU spenden)bash

# Nach der Installation einfach ausführen

python -m petals.cli.run_server meta-llama/Meta-Llama-3.1-405B-Instruct --public_name "DeinName"

Wichtige Flags:--num_blocks 8 → nur 8 Layer hosten (spart VRAM)
--port 31330
--cache_dir /pfad/zu/grossem/ssd

Aktueller Stand (Mai 2026)Das Projekt ist stabil, aber nicht mehr super-aktiv weiterentwickelt (letzte größere Commits 2024).
Öffentlicher Swarm funktioniert noch, vor allem für Llama 3.1 405B, Mixtral, Falcon etc.
Geschwindigkeit im öffentlichen Swarm: typisch 4–8 Tokens/s je nach Auslastung und Modell.
Private Swarms sind sehr gut möglich und oft schneller/stabiler.

Nützliche LinksHaupt-Repo: <https://github.com/bigscience-workshop/petals>
Swarm Monitor (wer hostet gerade was): <https://health.petals.dev>
Chat-Demo: <https://chat.petals.dev>
Discord für Hilfe: <https://discord.gg/KdThf2bWVU>

Tipp für dich: Starte zuerst im Colab, um zu sehen, wie stabil der aktuelle Swarm ist. Danach kannst du entscheiden, ob du einen eigenen Server oder sogar einen privaten Swarm mit Freunden aufbaust.Viel Erfolg beim Aufsetzen!
Schreib mir gerne, auf welchem System (Linux, Windows WSL, Mac, etc.) du es installierst und wo du hängen bleibst – dann helfe ich dir Schritt für Schritt weiter.
