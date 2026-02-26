# Dash Runner — Multi-Axis Redesign — Game Design Document

**Date:** 2026-02-22
**Status:** Approved
**Supersedes:** `2026-02-22-dash-runner-design.md` (original single-axis design)
**Platform:** Android
**Engine:** Godot 4.x
**Language:** GDScript

---

## Concept

Dash Runner evolves from a single-direction endless runner into a **multi-axis runner with 4 directional levels**, inspired by Terraria. The player traverses procedurally selected levels — a river, a platform, a hellevator, and a UFO abduction — each scrolling in a different axis. Levels are connected by teleporters. Difficulty scales dynamically based on accumulated XP.

**Primary Goal:** Learning Godot game development with a focus on reusable, data-driven architecture.

---

## Architecture Approach: Direction as Vector2

All core systems (scroller, spawner, player) receive a `scroll_direction: Vector2` and a `dodge_direction: Vector2` from the level configuration. Logic uses these vectors generically instead of hardcoding axes. This avoids code duplication across directions and makes adding new directions trivial.

**Trade-offs considered:**
- ~~World Rotation~~ — Rejected: sprite rotation and gravity rotation in Godot 2D are awkward
- ~~Separate scene per direction~~ — Rejected: massive code duplication (4x every system)
- **Vector2 direction** — Chosen: generic, clean, educational, extensible

---

## Level System (Data-Driven)

### LevelData Resource

Each level is defined as a `Resource` (`.tres` file):

```
LevelData (Resource)
├── level_name: String              # "Río", "Hellevator", etc.
├── scroll_direction: Vector2       # (1,0), (-1,0), (0,1), (0,-1)
├── dodge_direction: Vector2        # perpendicular to scroll
├── base_speed: float               # base scroll speed
├── base_distance: float            # base distance to complete level
├── distance_scale_per_xp: float    # how much distance grows per XP
├── gravity_enabled: bool           # true for horizontal, false for vertical
├── gravity_direction: Vector2      # (0,1) normal, (0,0) if none
├── obstacle_types: Array[PackedScene]  # obstacles this level can spawn
├── coin_frequency: float           # distance between coin spawns
├── obstacle_min_gap: float         # minimum space between obstacles
├── obstacle_max_gap: float         # maximum space between obstacles
├── ground_texture: Texture2D       # terrain/wall tile
├── bg_color: Color                 # background color
├── music_track: AudioStream        # (future) level music
```

### The 4 Initial Levels

| Level | scroll_direction | dodge_direction | gravity_enabled | Theme |
|-------|-----------------|-----------------|-----------------|-------|
| Río | `(1, 0)` | `(0, -1)` | `true` | Water, grass, rocks |
| Plataforma | `(-1, 0)` | `(0, -1)` | `true` | Stone, caves |
| Hellevator | `(0, 1)` | `(1, 0)` | `false` | Lava, dark stone |
| Abducción OVNI | `(0, -1)` | `(1, 0)` | `false` | Night sky, stars |

### Level Transitions

- On game start: a random level is selected from the 4
- On level completion: player touches a Teleporter → transition animation → next random level (no consecutive repeats)
- The cycle is infinite until the player dies

---

## Scene Architecture

### Scene Tree

```
Main (Node2D)                          # Persistent root scene
├── GameManager (Autoload)             # XP, score, global state
├── TransitionManager (Autoload)       # Level switching, teleporter logic
├── SwipeDetector (Autoload)           # Touch input in all 4 directions
│
└── Level (Node2D)                     # Instantiated per level, destroyed on switch
    ├── Camera2D                       # Centered on player
    ├── Background (ParallaxBackground)
    │   └── ParallaxLayer              # Scrolls according to scroll_direction
    ├── World (Node2D)                 # Container for all scrolling content
    │   ├── TerrainManager (Node2D)    # Infinite tiles (floor OR walls depending on axis)
    │   ├── ObstacleSpawner (Node2D)   # Spawns on scroll axis
    │   └── CoinSpawner (Node2D)       # Spawns coins/XP
    ├── Player (CharacterBody2D)       # Fixed on scroll axis, free on dodge axis
    ├── Teleporter (Area2D)            # Appears when level distance is completed
    └── UI (CanvasLayer)
        ├── ScoreLabel                 # Current XP
        ├── DistanceBar                # Level progress bar
        └── LevelIndicator             # Current level name
```

### Autoloads (Singletons)

| Autoload | Responsibility |
|----------|----------------|
| `GameManager` | Persistent XP, high score, game state (playing/dead/menu), save/load |
| `TransitionManager` | Picks next level, instantiates Level scene, teleporter animation |
| `SwipeDetector` | Detects swipe in 4 directions, emits signals (swiped_up, swiped_down, swiped_left, swiped_right) |

### Key Design Decisions

- `Main` persists always; `Level` is instantiated as a child and destroyed on switch
- This avoids `change_scene_to_file()` which destroys everything — Autoloads keep state naturally
- Teleporter transition is a smooth animation, not an abrupt scene cut

---

## Player System

### Two Modes Based on Level Type

**Horizontal levels (Río, Plataforma):**
- Fixed on scroll axis (X)
- Moves on Y axis (jump/crouch)
- Gravity active (falls down, lands on floor)
- `is_on_floor()` works normally
- Swipe up → jump (Y- impulse)
- Swipe down → crouch (shrink collision)

**Vertical levels (Hellevator, Abducción):**
- Fixed on scroll axis (Y)
- Moves on X axis (dodge left/right)
- No gravity — player floats at fixed Y position
- 3-lane system: left (-150), center (0), right (+150)
- Swipe left → move to left lane
- Swipe right → move to right lane
- Player stays in lane until next swipe

### Lane System for Vertical Levels

3 lanes instead of free movement:
- Obstacles designed to block 1-2 lanes maximum
- Always at least 1 lane free (guaranteed escapable)
- Simpler to balance, more fair, standard mobile runner pattern
- Smooth tween animation between lanes

### Player State Machine

```
States: RUNNING, JUMPING, CROUCHING, DODGING, DEAD

Horizontal mode: RUNNING → JUMPING → RUNNING
                 RUNNING → CROUCHING → RUNNING
Vertical mode:   RUNNING → DODGING → RUNNING
Any mode:        * → DEAD (on obstacle collision)
```

---

## Core Systems

### WorldScroller

Moves all children in the opposite direction of `scroll_direction`:

```
scroll_vector = -level_data.scroll_direction
movement = scroll_vector * current_speed * delta
```

Tracks `distance_traveled` to trigger teleporter spawn.

### TerrainManager

Generates infinite scrolling tiles. Recycle direction depends on axis:

| Level | Tiles represent | Recycle on |
|-------|----------------|------------|
| Río (X+) | Floor below | X axis (left → right) |
| Plataforma (X-) | Floor below | X axis (right → left) |
| Hellevator (Y+) | Side walls | Y axis (up → down) |
| Abducción (Y-) | Side walls | Y axis (down → up) |

In vertical levels, walls are decorative only. Obstacles occupy lanes.

### ObstacleSpawner

- Calculates `spawn_edge` once during `configure()` based on `scroll_direction`
- Spawns obstacles at the leading edge of scroll + offset on dodge axis
- Horizontal levels: obstacles at ground level (jump over) or aerial (crouch under)
- Vertical levels: obstacles occupy 1-2 of 3 lanes
- Destroys obstacles when past the trailing edge

### CoinSpawner

Same logic as ObstacleSpawner but for collectibles:
- Horizontal: coins at varying heights
- Vertical: coins in free lanes (never where obstacles are)

### Teleporter

1. When `distance_traveled >= calculated_level_distance`, Teleporter is instantiated at spawn edge
2. Teleporter scrolls with the world toward the player
3. Player touches Teleporter → `GameManager.complete_level()` → `TransitionManager.next_level()`
4. Transition animation plays → new Level instantiated → old Level destroyed

---

## XP and Progression System

### XP as Core Currency

XP replaces "score" from the original design. It is persistent across sessions.

| Action | XP Effect |
|--------|-----------|
| Collect coin | +10 XP (configurable per level) |
| Complete level (touch teleporter) | +50 XP bonus |
| Die | -20% of total XP (minimum 0) |

### Difficulty Scaling

```
difficulty_level = total_xp / 100    # every 100 XP = 1 difficulty level

Level distance:  base_distance + (difficulty_level * distance_scale_per_xp)
Scroll speed:    base_speed + (difficulty_level * 15.0)
Obstacle gaps:   max(obstacle_min_gap, obstacle_max_gap - difficulty_level * 10.0)
```

The 20% death penalty creates a self-regulating difficulty curve:
- High XP → high difficulty → more deaths → XP drops → difficulty drops → accessible again
- Prevents players from getting permanently stuck

### Persistence

Save file at `user://savegame.save` using `FileAccess`:

```
Save data:
  - total_xp: int
  - high_score: int (best session_xp)
  - levels_completed: int (lifetime total)
```

### Session Flow

```
MAIN MENU
  └─ Show: total XP, high score, "PLAY"
  └─ Click PLAY
      │
      ▼
TRANSITION MANAGER
  └─ Pick random level from 4
  └─ Calculate difficulty from current XP
  └─ Instantiate Level with LevelData
      │
      ▼
GAMEPLAY (LEVEL)
  └─ Scrolling + obstacles + coins
  └─ XP increases with collected coins
  └─ Progress bar shows remaining distance
  │
  ├─ On DEATH:
  │   └─ XP -= 20%
  │   └─ Save XP
  │   └─ Game Over screen (current XP, session XP, high score)
  │   └─ "Retry" → TRANSITION MANAGER (new random level)
  │   └─ "Menu" → MAIN MENU
  │
  └─ On LEVEL COMPLETE (touch teleporter):
      └─ XP += bonus
      └─ Teleport animation
      └─ TRANSITION MANAGER → next random level
      └─ Infinite loop until death
```

---

## Controls

### SwipeDetector (Autoload)

Detects touch gestures and keyboard fallback:

| Signal | Touch | Keyboard |
|--------|-------|----------|
| `swiped_up` | Swipe up | W / Space / Up Arrow |
| `swiped_down` | Swipe down | S / Down Arrow |
| `swiped_left` | Swipe left | A / Left Arrow |
| `swiped_right` | Swipe right | D / Right Arrow |

The Player connects to these signals and maps them based on level type:

| Level type | swiped_up/right | swiped_down/left |
|------------|----------------|-----------------|
| Horizontal | Jump | Crouch |
| Vertical | Move to next lane | Move to previous lane |

---

## Visual Style & Assets

### Kenney Pixel Platformer Pack (CC0)

Used directly — no placeholders. Sprites assigned from project start:
- Player character: Kenney character tiles
- Ground/wall tiles: Kenney tileset per level theme
- Obstacles: Kenney rocks, spikes, crates
- Coins: Kenney coin sprite (animated rotation)

### Per-Level Visual Identity

| Level | Ground/Walls | Background | Obstacles |
|-------|-------------|------------|-----------|
| Río | Grass tiles | Blue sky | Rocks, bushes |
| Plataforma | Stone tiles | Dark cave | Stalactites, spikes |
| Hellevator | Dark stone walls | Lava glow | Wall spikes, fire |
| Abducción | Metal walls | Night sky + stars | Lasers, drones |

---

## Screens

### Main Menu
- Game title: "DASH RUNNER"
- "PLAY" button
- Total XP display
- High score display

### Gameplay HUD
- XP counter (top-left)
- Level progress bar (top, full width)
- Level name indicator (top-center, fades after 2s)

### Game Over
- "GAME OVER"
- Session XP gained
- XP penalty shown (-X%)
- New total XP
- High score (with "NEW!" if beaten)
- "RETRY" button
- "MENU" button

### Teleporter Transition
- Brief animation (player steps on teleporter → flash → new level fades in)
- Level name appears briefly

---

## Target Platform

- **Android only** (landscape)
- Godot 4.x with Android export template
- Touch input (swipe gestures in 4 directions)
- Keyboard fallback for PC testing
- Resolution: 1920x1080 landscape
- Stretch mode: `canvas_items`, aspect: `keep_height`
- Minimum API: Android 7.0+ (SDK 24)

---

## Future Considerations (Post-MVP)

From Ideas column in Kanban:
- Custom sprites inspired by Terraria
- Weapons system (melee + ranged)
- Power-ups (shield, magnet, slow-mo)
- More level types (diagonal scroll, gravity flip)
- Sound effects and music per level
- Character selection / unlockables
- Play Store publication
