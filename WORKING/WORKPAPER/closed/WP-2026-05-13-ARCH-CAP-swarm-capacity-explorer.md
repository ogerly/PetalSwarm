# WP-2026-05-13-ARCH-CAP — Swarm Capacity Explorer

**Datum:** 2026-05-13
**Status:** Offen — kann parallel zu WP-GATE/WP-DASH entwickelt werden
**Referenz:** WH-001-ARCH-system-architektur.md (Sektionen 4, 5)
**Einordnung:** Neues Dashboard-Panel, erweitert WP-DASH

---

## Session Goal

Ein neues Dashboard-Panel zeigt die **Gesamtkapazität des Swarms** in Echtzeit:
Welche Nodes sind da, was bringen sie mit, und welche Modelle könnten wir damit fahren?

---

## Die Idee

Wenn jemand dem Netzwerk beitritt, soll er sofort sehen:

1. **"Ich bin dabei"** — sein eigener Node erscheint mit GPU-Name, VRAM, Status
2. **"Das sind die anderen"** — alle Peers mit ihren Specs
3. **"Das haben wir zusammen"** — Gesamt-VRAM, Gesamt-TFLOPS, Bandbreite
4. **"Das können wir damit"** — welche Modelle in welcher Quantisierung passen

Das ist ein **Forschungstool**, kein Monitoring. Es beantwortet:
*"Was wäre möglich, wenn wir alle zusammenarbeiten?"*

---

## UI-Konzept

### Panel 1: SWARM AGGREGATE (oben, prominent)

```
┌──────────────────────────────────────────────────┐
│  ◉ SWARM CAPACITY                                │
│                                                  │
│   NODES        TOTAL VRAM       EST. TFLOPS      │
│    ╔═══╗        ╔══════╗        ╔═════════╗      │
│    ║ 4 ║        ║ 84 GB║        ║ 312 TF  ║      │
│    ╚═══╝        ╚══════╝        ╚═════════╝      │
│                                                  │
│   ▸ Upload BW: ~280 Mbit/s combined              │
│   ▸ Bottleneck: Node #3 (50 Mbit/s upload)       │
└──────────────────────────────────────────────────┘
```

### Panel 2: NODE REGISTRY (Detail-Liste)

```
┌──────────────────────────────────────────────────┐
│  ◉ NODE REGISTRY · 4 peers                      │
│                                                  │
│  ● node-alpha    RTX 5090   32 GB  ████████ 100% │
│    ↳ 210 TFLOPS · 500 Mbit/s · Blocks: 0-60     │
│                                                  │
│  ● node-beta     RTX 3090   24 GB  ██████── 75%  │
│    ↳ 71 TFLOPS  · 100 Mbit/s · Blocks: 60-80    │
│                                                  │
│  ● node-gamma    RTX 4060    8 GB  ██───── 25%   │
│    ↳ 24 TFLOPS  · 50 Mbit/s  · idle             │
│                                                  │
│  ★ YOU (node-delta) RTX 4090  24 GB ██████── 75% │
│    ↳ 83 TFLOPS  · 200 Mbit/s · Blocks: idle     │
│    ↳ "Dein Node ist aktiv im Swarm!"             │
└──────────────────────────────────────────────────┘
```

### Panel 3: MODEL FEASIBILITY MATRIX (Kernstück)

```
┌──────────────────────────────────────────────────┐
│  ◉ MODEL FEASIBILITY · based on 84 GB total VRAM│
│                                                  │
│  Modell                Q4_K_M   Q3_K_S   Q2_K   │
│  ─────────────────────────────────────────────── │
│  Llama 3.2 3B           ✅ 2GB   ✅ 1.5   ✅ 1   │
│  Mistral 7B             ✅ 4GB   ✅ 3     ✅ 2.5  │
│  Llama 3.1 8B           ✅ 5GB   ✅ 4     ✅ 3    │
│  Llama 3.1 70B          ✅ 42GB  ✅ 28    ✅ 22   │
│  Llama 3.1 405B         ❌ 240   ❌ 180   ❌ 140  │
│  Mixtral 8x22B          ✅ 80GB  ✅ 60    ✅ 48   │
│  DeepSeek-V3 671B       ❌ 390   ❌ 290   ❌ 230  │
│                                                  │
│  ✅ = passt in Swarm   ❌ = nicht genug VRAM     │
│  ────────────────────────────────────────────────│
│  EMPFEHLUNG bei 84 GB:                           │
│  → Llama 3.1 70B @ Q4_K_M  ~18 tok/s (2 Nodes)  │
│  → Mixtral 8x22B @ Q3_K_S  ~12 tok/s (3 Nodes)  │
└──────────────────────────────────────────────────┘
```

---

## Datenmodell

### Node-Info (vom Gateway: `GET /swarm/peers`)

```json
{
  "peer_id": "12D3KooW...",
  "public_name": "node-alpha",
  "gpu": "RTX 5090",
  "vram_gb": 32,
  "vram_used_gb": 28.4,
  "estimated_tflops": 210,
  "upload_mbps": 500,
  "blocks_serving": [0, 60],
  "status": "serving",
  "joined_at": "2026-05-13T10:15:00Z",
  "is_self": false
}
```

### Swarm-Aggregat (berechnet im Frontend)

```json
{
  "total_nodes": 4,
  "total_vram_gb": 84,
  "total_vram_free_gb": 27.6,
  "total_tflops": 312,
  "combined_upload_mbps": 850,
  "bottleneck_upload_mbps": 50,
  "bottleneck_node": "node-gamma"
}
```

### Model-Feasibility (statische Lookup-Tabelle + dynamische Berechnung)

```javascript
const MODEL_SPECS = [
  { name: "Llama 3.2 3B",     params_b: 3,    vram_q4: 2,   vram_q3: 1.5,  vram_q2: 1    },
  { name: "Mistral 7B",       params_b: 7,    vram_q4: 4,   vram_q3: 3,    vram_q2: 2.5  },
  { name: "Llama 3.1 8B",     params_b: 8,    vram_q4: 5,   vram_q3: 4,    vram_q2: 3    },
  { name: "Llama 3.1 70B",    params_b: 70,   vram_q4: 42,  vram_q3: 28,   vram_q2: 22   },
  { name: "Mixtral 8x22B",    params_b: 141,  vram_q4: 80,  vram_q3: 60,   vram_q2: 48   },
  { name: "Llama 3.1 405B",   params_b: 405,  vram_q4: 240, vram_q3: 180,  vram_q2: 140  },
  { name: "DeepSeek-V3 671B", params_b: 671,  vram_q4: 390, vram_q3: 290,  vram_q2: 230  },
];

function checkFeasibility(model, totalVram) {
  return {
    q4: totalVram >= model.vram_q4,
    q3: totalVram >= model.vram_q3,
    q2: totalVram >= model.vram_q2,
    best_quant: totalVram >= model.vram_q4 ? "Q4_K_M"
              : totalVram >= model.vram_q3 ? "Q3_K_S"
              : totalVram >= model.vram_q2 ? "Q2_K"
              : null
  };
}
```

---

## Geschätzter tok/s-Rechner

Grobe Formel für verteilte Inference:

```
tok/s ≈ min(
  bottleneck_bandwidth_mbps / activation_size_mb,
  slowest_node_compute_tflops * efficiency_factor
)

activation_size_mb ≈ hidden_dim * 2 (bfloat16) / 1024 / 1024
efficiency_factor ≈ 0.4 (typisch für Pipeline-Parallelismus)
```

Für den Anfang reicht eine Lookup-Tabelle mit konservativen Schätzungen:

| Modell | 1 Node (5090) | 2 Nodes | 3+ Nodes |
|---|---|---|---|
| 3B Q4 | 120 tok/s | 120 | 120 (overkill) |
| 8B Q4 | 80 tok/s | 80 | 80 (overkill) |
| 70B Q3 | 15-20 tok/s | 25-30 | 35-40 |
| 70B Q4 | — (passt nicht) | 20-25 | 30-35 |

---

## Gateway-Erweiterung nötig

Neuer Endpunkt oder Erweiterung von `/swarm/status`:

```
GET /swarm/capacity → {
  nodes: [...],           // Detail je Node
  aggregate: {...},       // Gesamt-Stats
  feasible_models: [...], // Welche Modelle passen
  recommendation: {...}   // Beste Option
}
```

---

## Tasks

- [ ] Model-Specs Lookup-Tabelle erstellen (JS, statisch)
- [ ] Feasibility-Berechnung implementieren (rein clientseitig)
- [ ] Aggregat-Berechnung aus Peer-Daten
- [ ] "YOU" Marker: eigenen Node hervorheben
- [ ] 3 neue Panels im Dashboard: Aggregate, Registry, Feasibility
- [ ] Gateway erweitern: `/swarm/capacity` (optional, kann auch rein Frontend sein)
- [ ] tok/s Schätzungen als Tooltip/Detail

---

## Design-Entscheidungen

| Frage | Empfehlung | Grund |
|---|---|---|
| Berechnung: Frontend oder Backend? | Frontend | Model-Specs sind statisch, Aggregation trivial |
| Welche Modelle zeigen? | Top 7-10 bekannte | Zu viele verwirren |
| tok/s anzeigen? | Ja, als Schätzung mit Disclaimer | Forschungswert hoch |
| TFLOPS zeigen? | Ja, geschätzt aus GPU-Modell | Macht Beitrag greifbar |

---

## Definition of Done

- [ ] Swarm-Aggregat-Panel zeigt: Nodes, VRAM, TFLOPS
- [ ] Node Registry zeigt jeden Peer mit GPU-Details
- [ ] Eigener Node ist markiert ("YOU" / ★)
- [ ] Model Feasibility Matrix zeigt ✅/❌ für min. 5 Modelle
- [ ] Empfehlung: "Bestes Modell bei aktueller Kapazität"
- [ ] Alles aktualisiert sich bei Peer-Join/Leave

---

## Einordnung in Abhängigkeitskette

```
WP-ENV → WP-BOOT → WP-GATE → WP-DASH ──→ WP-SCALE
                        │
                        └──→ WP-CAP (dieses WP)
                              Frontend-only möglich,
                              profitiert aber von Gateway-Daten
```

Kann **parallel zu WP-DASH** entwickelt werden — die Model-Feasibility-Logik
und das UI sind rein Frontend und brauchen kein laufendes Gateway zum Entwickeln.
