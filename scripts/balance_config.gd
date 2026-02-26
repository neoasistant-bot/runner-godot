## balance_config.gd
## Centraliza todos los valores de balance del sistema de combate.
## Modificar aquí para ajustar sin tocar lógica.
extends Node

# ── Enemigos ──────────────────────────────────────────────────────────────────
const SLIME_SPEED     := 110.0
const SLIME_XP        := 10

const BAT_SPEED       := 160.0
const BAT_XP          := 15

const SKELETON_SPEED  := 130.0
const SKELETON_XP     := 25

const GHOST_SPEED     := 180.0
const GHOST_XP        := 20

# ── Spawn ─────────────────────────────────────────────────────────────────────
const SPAWN_INTERVAL_BASE := 5.0   # segundos entre spawns al inicio
const SPAWN_INTERVAL_MIN  := 1.8   # mínimo con dificultad máxima
const SPAWN_DIFFICULTY_STEP := 0.25 # reducción por nivel de dificultad

# ── Ataques del jugador ───────────────────────────────────────────────────────
const MELEE_DAMAGE    := 2
const MELEE_COOLDOWN  := 0.4
const MELEE_RANGE     := 150.0

const RANGED_DAMAGE   := 1
const RANGED_COOLDOWN := 0.8
const RANGED_SPEED    := 800.0

const DOUBLE_TAP_WINDOW := 0.3

# ── Hazards ───────────────────────────────────────────────────────────────────
const HAZARD_INTERVAL_BASE := 10.0
const HAZARD_INTERVAL_MIN  := 6.0
const LIGHTNING_WARNING    := 0.8
const SHOCKWAVE_WARNING    := 0.5
