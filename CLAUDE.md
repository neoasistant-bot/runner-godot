# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Dash Runner** is a 2D endless side-scrolling runner game built with Godot 4.x for Android. The player runs infinitely to the right (world scrolls left), using swipe gestures to jump over ground obstacles and crouch under aerial obstacles. The game features a zone-based procedural generation system with themed difficulty levels.

**Primary Goal:** Learning Godot game development

**Platform:** Android (landscape orientation)
**Engine:** Godot 4.4+
**Language:** GDScript
**Assets:** Kenney.nl pixel art (Pixel Platformer pack)

## Project Structure

```
dash-runner/
├── assets/
│   └── kenney/          # Pixel art sprites from Kenney.nl
├── scenes/              # All .tscn scene files
│   ├── game.tscn        # Main game scene
│   ├── player.tscn      # Player CharacterBody2D
│   ├── obstacle.tscn    # Obstacle Area2D
│   ├── coin.tscn        # Collectible coin Area2D
│   ├── main_menu.tscn   # Main menu screen
│   └── game_over.tscn   # Game over screen
├── scripts/             # All .gd script files
│   ├── player.gd
│   ├── swipe_detector.gd   # Autoload singleton for touch input
│   ├── game_manager.gd     # Autoload singleton for game state
│   ├── world_scroller.gd
│   ├── zone_manager.gd
│   ├── obstacle_spawner.gd
│   ├── coin_spawner.gd
│   └── zone_data.gd        # Resource class for zone definitions
├── data/                # Zone definition .tres resource files
│   ├── zone_safe_plains.tres
│   ├── zone_danger_cave.tres
│   └── zone_sky_bonus.tres
└── docs/
    └── plans/           # Design and implementation documentation
```

## Running the Project

**Godot Editor:**
1. Download Godot 4.4+ from https://godotengine.org/download
2. Open Godot → Import → Select `project.godot` in this directory
3. Press F5 to run the game

**Testing on PC:**
- Keyboard controls are implemented as fallback:
  - W / Space / Up Arrow → Jump
  - S / Down Arrow → Crouch

**Building for Android:**
1. Project → Export → Android
2. Ensure Android SDK and JDK 17 are configured in Editor Settings
3. Export debug APK to `build/dash-runner-debug.apk`
4. Install via `adb install build/dash-runner-debug.apk`

## Core Architecture

### Scene Tree
```
Game (Node2D)
├── ZoneManager (Node) — Controls zone transitions and difficulty
├── ParallaxBackground — Scrolling background layers
├── Ground (StaticBody2D) — WorldBoundaryShape2D for collision
├── World (Node2D) — Parent container for all scrolling elements
│   ├── GroundManager (Node2D) — Infinite tile scrolling
│   ├── ObstacleSpawner (Node2D) — Spawns obstacles
│   └── CoinSpawner (Node2D) — Spawns collectibles
├── Player (CharacterBody2D) — Player instance
└── UI (CanvasLayer) — HUD and overlays
```

### Key Systems

**Player Movement:**
- Player is stationary horizontally
- World scrolls left to create running illusion
- Player only moves vertically (jump/crouch)
- CharacterBody2D with gravity and collision detection

**Obstacle System:**
- Ground obstacles: Jump over (boxes, rocks)
- Aerial obstacles: Crouch under (stalactites, spikes)
- Area2D for detection, spawned off-screen right, destroyed off-screen left

**Zone System (Data-Driven):**
- Zones are defined as `ZoneData` resources (`.tres` files)
- Each zone specifies: visual style, obstacle frequency, coin frequency, speed modifier, duration
- ZoneManager handles transitions and applies parameters to spawners
- Zone cycle: Safe → Danger → Bonus → repeat

**Autoload Singletons:**
- `SwipeDetector`: Touch input detection (signals: `swiped_up`, `swiped_down`, `tapped`)
- `GameManager`: Game state management (score, high score, is_playing)

## GDScript Conventions

**Node References:**
- Use `$NodeName` for direct children
- Use `@onready` for complex node paths
- Example: `@onready var sprite: Sprite2D = $Sprite2D`

**Signals:**
- Use signals for decoupling (e.g., `SwipeDetector.swiped_up.connect(_on_swipe_up)`)
- Emit game events through GameManager (e.g., `GameManager.game_over.emit()`)

**Scrolling Pattern:**
- All scrolling objects implement `scroll(amount: float)` method
- World scroller calls `scroll()` on all children each frame
- Objects check `is_off_screen()` and recycle or destroy themselves

**Resource-Based Design:**
- Zone configurations are Resources, not hardcoded
- Use `@export` for scene configuration
- Example: `@export var zone_data: ZoneData`

## Common Development Tasks

**Run game from main menu:**
```bash
# Set main scene to main_menu.tscn in Project Settings
# F5 to run
```

**Test specific scene:**
```bash
# Open scene in editor
# F6 to run current scene
```

**Debug print:**
```gdscript
print("Debug message: ", variable_name)
```

**Scene transitions:**
```gdscript
get_tree().change_scene_to_file("res://scenes/game.tscn")
```

**File persistence (high score):**
```gdscript
const SAVE_PATH: String = "user://highscore.save"
var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
file.store_32(score)
```

## Implementation Plan

The complete step-by-step implementation plan is located in:
`docs/plans/2026-02-22-dash-runner-implementation.md`

When implementing features, follow the task order in the implementation plan. Each task includes:
- File creation/modification list
- Step-by-step instructions
- Verification criteria
- Git commit message

**IMPORTANT:** The implementation plan requires using the `superpowers:executing-plans` skill to implement tasks systematically.

## Git Workflow

**Commit message format:**
```
feat: description of feature
fix: description of bug fix
docs: documentation updates
refactor: code refactoring
```

**Gitignore:**
- `.godot/` — Godot editor cache
- `*.tmp`, `*.log` — Temporary files
- `export_presets.cfg` — Local export settings (contains keystore paths)
- `build/` — Compiled APKs

## Android Configuration

**Project Settings:**
- Viewport: 1920x1080 landscape
- Stretch mode: `canvas_items`
- Aspect: `keep_height`
- Orientation: `landscape`

**Export Settings:**
- Package name: `com.dashrunner.game`
- Min SDK: 24 (Android 7.0+)
- Target SDK: 33
- Screen orientation: Landscape

## Assets

**Kenney Pixel Platformer Pack:**
- Download from: https://kenney.nl/assets/pixel-platformer
- Extract to: `assets/kenney/`
- License: CC0 (public domain)

**Required sprites:**
- Player character (32x32px): run, jump, crouch, die
- Ground tiles per zone (grass, stone, clouds)
- Obstacle sprites (rocks, spikes, stalactites)
- Coin sprite (animated)
- Background layers

**Placeholder development:**
- Use ColorRect nodes as placeholders before importing sprites
- Replace placeholders with actual sprites in Task 12 of implementation plan

## Key Technical Notes

**Collision Layers:**
- Player: CharacterBody2D (for floor detection) + Area2D child (for obstacle detection)
- Ground: StaticBody2D with WorldBoundaryShape2D
- Obstacles/Coins: Area2D

**Crouch Mechanic:**
- Two collision shapes on player: standing (full height) and crouching (half height)
- Swap collision shapes when crouching
- Timed auto-standup after 0.5 seconds

**Speed Ramping:**
- Base speed increases every 10 seconds by 10 px/sec
- Max speed cap: 800 px/sec
- Zone speed modifiers apply multiplicatively

**Zone Transitions:**
- Zones change based on distance traveled
- Each zone has a `duration_distance` parameter
- ZoneManager emits `zone_changed` signal
- Spawners and world scroller listen and adjust parameters

## Troubleshooting

**Player falls through floor:**
- Check WorldBoundaryShape2D is positioned correctly (y = 500)
- Verify player CollisionShape2D is enabled
- Ensure CharacterBody2D gravity is applied

**Touch input not working:**
- SwipeDetector must be registered as Autoload
- Check InputEventScreenTouch events in _input()
- Test with keyboard fallback first

**Obstacles not spawning:**
- Verify obstacle_scene is assigned in ObstacleSpawner inspector
- Check scroll() method is being called from world_scroller
- Print debug in _spawn_obstacle()

**Zone not changing:**
- Ensure ZoneManager.update_distance() is called each frame
- Check zone resource files are assigned in inspector
- Verify current_zone.duration_distance is set correctly
