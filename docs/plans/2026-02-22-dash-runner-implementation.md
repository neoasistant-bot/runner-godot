# Dash Runner Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a 2D endless runner in Godot 4.x for Android, using swipe controls, zone-based procedural generation, and free pixel art assets.

**Architecture:** Side-scrolling runner where the world moves left while the player is stationary horizontally. Zones are data-driven dictionaries that define sprites, obstacle frequency, and speed. Scene tree uses CharacterBody2D for player, Area2D for collectibles/obstacles, and CanvasLayer for UI.

**Tech Stack:** Godot 4.4+, GDScript, Android export template, Kenney pixel art assets

**Design doc:** `docs/plans/2026-02-22-dash-runner-design.md`

---

## Prerequisites

- Download Godot 4.4+ from https://godotengine.org/download
- Extract to a known location (e.g., `C:\Tools\Godot\`)
- Download Kenney "Pixel Platformer" asset pack from https://kenney.nl/assets/pixel-platformer
- Extract assets to `dash-runner/assets/kenney/`

---

## Task 1: Project Setup & Scene Skeleton

**Goal:** Create the Godot project, configure settings, and build the empty scene tree.

**Files:**
- Create: `project.godot` (via Godot editor — New Project)
- Create: `scenes/game.tscn` (main game scene)
- Create: `scenes/player.tscn` (player scene)

**Step 1: Create the Godot project**

Open Godot → New Project → Browse to `C:\Users\Marti\Documents\proyectos\dash-runner\` → Project Name: "Dash Runner" → Renderer: "Mobile" → Create & Edit.

**Step 2: Configure project settings**

In Project → Project Settings:
- `display/window/size/viewport_width` = `1920`
- `display/window/size/viewport_height` = `1080`
- `display/window/stretch/mode` = `canvas_items`
- `display/window/stretch/aspect` = `keep_height`
- `display/window/handheld/orientation` = `landscape`

**Step 3: Create folder structure**

In the FileSystem dock, create these folders:
```
res://
├── assets/          (sprites, tilesets, fonts)
├── scenes/          (all .tscn scene files)
├── scripts/         (all .gd script files)
└── data/            (zone definitions, game config)
```

**Step 4: Create the main Game scene**

Create a new scene with root `Node2D`, name it "Game". Save as `scenes/game.tscn`.

Add child nodes:
```
Game (Node2D)
├── World (Node2D)
├── Player (CharacterBody2D)  ← will be its own scene later
├── UI (CanvasLayer)
```

Set `scenes/game.tscn` as the main scene in Project → Project Settings → Application → Run → Main Scene.

**Step 5: Verify — Run the project**

Press F5. Expected: A blank grey window opens at 1920x1080 landscape. No errors in the Output panel.

**Step 6: Initialize git and commit**

```bash
cd /c/Users/Marti/Documents/proyectos/dash-runner
git init
```

Create `.gitignore`:
```
# Godot
.godot/
*.tmp
*.log
export_presets.cfg

# OS
Thumbs.db
.DS_Store
```

```bash
git add -A
git commit -m "feat: initial Godot project setup with scene skeleton"
```

---

## Task 2: Player Scene — Sprite, Collision & Gravity

**Goal:** Create the player as a separate scene with sprite, collision box, and gravity so it falls and lands on the ground.

**Files:**
- Create: `scenes/player.tscn`
- Create: `scripts/player.gd`
- Modify: `scenes/game.tscn` (add ground + instantiate player)

**Step 1: Import player sprite**

Copy the Kenney character sprite into `assets/kenney/`. In the Godot editor, the asset will auto-import.

If Kenney pack not downloaded yet, create a temporary colored rectangle:
- In `scenes/player.tscn`, add a `ColorRect` child (32x64 px, blue) as placeholder.

**Step 2: Build the Player scene**

Create a new scene → Root: `CharacterBody2D` → Name: "Player"

Add children:
```
Player (CharacterBody2D)
├── Sprite2D           (or ColorRect placeholder)
├── CollisionShape2D   (RectangleShape2D, match sprite size)
```

For CollisionShape2D:
- Shape: `RectangleShape2D`
- Size: `Vector2(28, 56)` (slightly smaller than sprite for forgiving hitbox)

Save as `scenes/player.tscn`.

**Step 3: Write player.gd with gravity + ground detection**

Attach a new script to Player node. Save as `scripts/player.gd`:

```gdscript
extends CharacterBody2D

const GRAVITY: float = 1200.0

func _physics_process(delta: float) -> void:
    # Apply gravity
    if not is_on_floor():
        velocity.y += GRAVITY * delta

    move_and_slide()
```

**Step 4: Add a ground to the Game scene**

In `scenes/game.tscn`, add to the World node:
```
World (Node2D)
└── Ground (StaticBody2D)
    ├── CollisionShape2D  (WorldBoundaryShape2D or RectangleShape2D)
    └── ColorRect          (visual — green rectangle, 1920x100)
```

Position the ground at `y = 500` (bottom area of 1080 viewport).
For CollisionShape2D, use `WorldBoundaryShape2D` (infinite horizontal plane) or a wide `RectangleShape2D`.

**Step 5: Instance the Player scene in Game**

In `scenes/game.tscn`:
- Delete the placeholder CharacterBody2D if present
- Add a child → Instance a scene → select `scenes/player.tscn`
- Position Player at `Vector2(200, 300)` (above the ground, so gravity pulls it down)

**Step 6: Verify — Run and check gravity**

Press F5. Expected:
- The blue rectangle (player) falls from position (200, 300)
- Lands on the green ground and stops
- No jittering or falling through the floor

**Step 7: Commit**

```bash
git add scenes/player.tscn scripts/player.gd scenes/game.tscn
git commit -m "feat: player scene with gravity and ground collision"
```

---

## Task 3: Swipe Input Detection

**Goal:** Detect swipe up and swipe down gestures on touchscreen (and keyboard fallback for testing on PC).

**Files:**
- Modify: `project.godot` (InputMap actions)
- Create: `scripts/swipe_detector.gd` (reusable swipe detection)
- Modify: `scripts/player.gd` (respond to swipe)

**Step 1: Configure InputMap actions**

In Project → Project Settings → Input Map, add:
- `jump` → Key: W, Key: Space, Key: Up Arrow
- `crouch` → Key: S, Key: Down Arrow

(Touch input will be handled in code via `_input()` since swipe requires tracking touch start/end.)

**Step 2: Create swipe_detector.gd**

Create `scripts/swipe_detector.gd` as an Autoload (singleton):

```gdscript
extends Node

signal swiped_up
signal swiped_down
signal tapped

const SWIPE_THRESHOLD: float = 50.0  # minimum pixels to count as swipe
const TAP_THRESHOLD: float = 20.0    # max movement to count as tap

var _touch_start: Vector2 = Vector2.ZERO
var _touch_start_time: int = 0
var _is_touching: bool = false

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            _touch_start = event.position
            _touch_start_time = Time.get_ticks_msec()
            _is_touching = true
        else:
            if _is_touching:
                _process_gesture(event.position)
                _is_touching = false

func _process_gesture(end_pos: Vector2) -> void:
    var diff: Vector2 = end_pos - _touch_start
    var duration: int = Time.get_ticks_msec() - _touch_start_time

    if diff.length() < TAP_THRESHOLD and duration < 300:
        tapped.emit()
        return

    if abs(diff.y) > SWIPE_THRESHOLD and abs(diff.y) > abs(diff.x):
        if diff.y < 0:
            swiped_up.emit()
        else:
            swiped_down.emit()
```

**Step 3: Register as Autoload**

Project → Project Settings → Autoload → Add:
- Path: `res://scripts/swipe_detector.gd`
- Name: `SwipeDetector`

**Step 4: Update player.gd to listen for swipe + keyboard**

```gdscript
extends CharacterBody2D

const GRAVITY: float = 1200.0
const JUMP_VELOCITY: float = -600.0

var _is_crouching: bool = false

func _ready() -> void:
    SwipeDetector.swiped_up.connect(_on_swipe_up)
    SwipeDetector.swiped_down.connect(_on_swipe_down)

func _physics_process(delta: float) -> void:
    # Apply gravity
    if not is_on_floor():
        velocity.y += GRAVITY * delta
    else:
        _is_crouching = false

    # Keyboard fallback (for PC testing)
    if Input.is_action_just_pressed("jump") and is_on_floor():
        _jump()
    if Input.is_action_just_pressed("crouch") and is_on_floor():
        _crouch()

    move_and_slide()

func _jump() -> void:
    if is_on_floor():
        velocity.y = JUMP_VELOCITY

func _crouch() -> void:
    if is_on_floor():
        _is_crouching = true
        # TODO: shrink collision box, change sprite

func _on_swipe_up() -> void:
    _jump()

func _on_swipe_down() -> void:
    _crouch()
```

**Step 5: Verify — Test jump with keyboard**

Press F5. Press Space or W:
- Player jumps upward with arc
- Falls back to ground naturally
- Can't jump while in the air (no double jump)
- Press S: `_is_crouching` becomes true (check via print debug)

**Step 6: Commit**

```bash
git add scripts/swipe_detector.gd scripts/player.gd project.godot
git commit -m "feat: swipe detection and jump/crouch input handling"
```

---

## Task 4: World Scrolling & Infinite Ground

**Goal:** Make the ground scroll infinitely to the left, creating the running illusion. Add a parallax background.

**Files:**
- Create: `scripts/world_scroller.gd`
- Create: `scripts/ground_manager.gd`
- Modify: `scenes/game.tscn` (add ParallaxBackground)

**Step 1: Create world_scroller.gd**

Attach to the World node in `scenes/game.tscn`:

```gdscript
extends Node2D

var scroll_speed: float = 300.0
var _is_running: bool = true

func _process(delta: float) -> void:
    if not _is_running:
        return

    # Move all children to the left
    for child in get_children():
        if child.has_method("scroll"):
            child.scroll(scroll_speed * delta)

func stop() -> void:
    _is_running = false

func increase_speed(amount: float) -> void:
    scroll_speed += amount
```

**Step 2: Create ground tiles that recycle**

Create `scripts/ground_manager.gd`:

```gdscript
extends Node2D

@export var tile_scene: PackedScene
@export var tile_width: float = 256.0
@export var ground_y: float = 500.0

var _tiles: Array[Node2D] = []
var _viewport_width: float

func _ready() -> void:
    _viewport_width = get_viewport_rect().size.x
    _spawn_initial_tiles()

func _spawn_initial_tiles() -> void:
    var count: int = ceili(_viewport_width / tile_width) + 2
    for i in count:
        var tile: Node2D = _create_tile()
        tile.position = Vector2(i * tile_width, ground_y)
        _tiles.append(tile)
        add_child(tile)

func _create_tile() -> Node2D:
    if tile_scene:
        return tile_scene.instantiate()
    # Fallback: colored rectangle
    var rect := ColorRect.new()
    rect.size = Vector2(tile_width, 100)
    rect.color = Color.DARK_GREEN
    return rect

func scroll(amount: float) -> void:
    for tile in _tiles:
        tile.position.x -= amount
        # Recycle: if tile is fully off-screen left, move to the right end
        if tile.position.x < -tile_width:
            var rightmost_x: float = _get_rightmost_x()
            tile.position.x = rightmost_x + tile_width

func _get_rightmost_x() -> float:
    var max_x: float = -INF
    for tile in _tiles:
        if tile.position.x > max_x:
            max_x = tile.position.x
    return max_x
```

**Step 3: Set up in Game scene**

In `scenes/game.tscn`, restructure World:
```
World (Node2D)  ← attach world_scroller.gd
├── GroundManager (Node2D)  ← attach ground_manager.gd
└── (ObstacleSpawner — later)
```

Remove the old StaticBody2D ground. The GroundManager creates visual tiles.

For collision, add a single `StaticBody2D` with `WorldBoundaryShape2D` at `y = 500` as a sibling of World (so it doesn't scroll — the floor is always there).

**Step 4: Add a simple parallax background**

In `scenes/game.tscn`, add above World:
```
Game (Node2D)
├── ParallaxBackground
│   └── ParallaxLayer (motion_scale = Vector2(0.3, 0))
│       └── ColorRect (sky blue, 3840x1080)
├── Ground (StaticBody2D + WorldBoundaryShape2D at y=500)
├── World (Node2D)
│   └── GroundManager (Node2D)
├── Player (CharacterBody2D)
└── UI (CanvasLayer)
```

The ParallaxLayer with `motion_scale = 0.3` creates a parallax effect. For now, a solid color is fine. We'll replace with sprite later.

**Step 5: Verify — Run and see scrolling**

Press F5. Expected:
- Green ground tiles scroll left continuously
- When a tile goes off-screen left, it reappears on the right (seamless loop)
- Player stands on the ground (collision still works via WorldBoundaryShape2D)
- Player can still jump
- Background scrolls slower than ground (parallax)

**Step 6: Commit**

```bash
git add scripts/world_scroller.gd scripts/ground_manager.gd scenes/game.tscn
git commit -m "feat: infinite scrolling ground with parallax background"
```

---

## Task 5: Obstacle Spawner & Collision (Game Over)

**Goal:** Spawn obstacles that scroll with the world. Hitting one triggers game over.

**Files:**
- Create: `scenes/obstacle.tscn`
- Create: `scripts/obstacle.gd`
- Create: `scripts/obstacle_spawner.gd`
- Modify: `scripts/player.gd` (death handling)
- Create: `scripts/game_manager.gd` (game state)

**Step 1: Create the Obstacle scene**

New scene → Root: `Area2D` → Name: "Obstacle"

```
Obstacle (Area2D)
├── Sprite2D (or ColorRect placeholder — red, 40x60)
├── CollisionShape2D (RectangleShape2D matching sprite)
```

Save as `scenes/obstacle.tscn`.

**Step 2: Write obstacle.gd**

```gdscript
extends Area2D

enum Type { GROUND, AERIAL }

@export var obstacle_type: Type = Type.GROUND

func scroll(amount: float) -> void:
    position.x -= amount

func is_off_screen() -> bool:
    return position.x < -100
```

**Step 3: Write obstacle_spawner.gd**

```gdscript
extends Node2D

@export var obstacle_scene: PackedScene
@export var min_gap: float = 400.0
@export var max_gap: float = 700.0
@export var ground_y: float = 460.0   # just above ground level
@export var aerial_y: float = 350.0   # for crouch-under obstacles

var _distance_since_last: float = 0.0
var _next_spawn_distance: float = 0.0
var _obstacles: Array[Node2D] = []
var _is_active: bool = true

func _ready() -> void:
    _next_spawn_distance = randf_range(min_gap, max_gap)

func scroll(amount: float) -> void:
    if not _is_active:
        return

    _distance_since_last += amount

    # Move existing obstacles
    var to_remove: Array[int] = []
    for i in _obstacles.size():
        _obstacles[i].scroll(amount)
        if _obstacles[i].is_off_screen():
            to_remove.append(i)

    # Remove off-screen obstacles (reverse to keep indices valid)
    for i in range(to_remove.size() - 1, -1, -1):
        _obstacles[to_remove[i]].queue_free()
        _obstacles.remove_at(to_remove[i])

    # Spawn new obstacle if enough distance
    if _distance_since_last >= _next_spawn_distance:
        _spawn_obstacle()
        _distance_since_last = 0.0
        _next_spawn_distance = randf_range(min_gap, max_gap)

func _spawn_obstacle() -> void:
    var obs: Area2D = obstacle_scene.instantiate()

    # Randomly choose ground or aerial
    if randf() > 0.7:
        obs.obstacle_type = obs.Type.AERIAL
        obs.position = Vector2(get_viewport_rect().size.x + 100, aerial_y)
    else:
        obs.obstacle_type = obs.Type.GROUND
        obs.position = Vector2(get_viewport_rect().size.x + 100, ground_y)

    _obstacles.append(obs)
    add_child(obs)

func stop() -> void:
    _is_active = false
```

**Step 4: Create game_manager.gd (Autoload)**

```gdscript
extends Node

signal game_over
signal game_started

var is_playing: bool = false
var score: float = 0.0

func start_game() -> void:
    score = 0.0
    is_playing = true
    game_started.emit()

func end_game() -> void:
    is_playing = false
    game_over.emit()
```

Register as Autoload: name `GameManager`.

**Step 5: Update player.gd — detect obstacle collision**

Add to player.gd `_ready()`:

```gdscript
func _ready() -> void:
    SwipeDetector.swiped_up.connect(_on_swipe_up)
    SwipeDetector.swiped_down.connect(_on_swipe_down)
    # Connect to all Area2D that enter our body
    # We need an Area2D on the player too, OR use body_entered on obstacles
```

Actually, since obstacles are Area2D, add an Area2D to the Player scene as a hitbox detector, then connect its signal:

In `scenes/player.tscn`, add:
```
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D         (for physics/floor)
├── HitboxArea (Area2D)      (for obstacle detection)
│   └── CollisionShape2D     (same size as player)
```

In player.gd:
```gdscript
func _ready() -> void:
    SwipeDetector.swiped_up.connect(_on_swipe_up)
    SwipeDetector.swiped_down.connect(_on_swipe_down)
    $HitboxArea.area_entered.connect(_on_hitbox_area_entered)

func _on_hitbox_area_entered(area: Area2D) -> void:
    if area.is_in_group("obstacles"):
        _die()

func _die() -> void:
    GameManager.end_game()
    # TODO: play death animation
    set_physics_process(false)
```

Add obstacles to the "obstacles" group: in obstacle.gd `_ready()`:
```gdscript
func _ready() -> void:
    add_to_group("obstacles")
```

**Step 6: Wire up Game scene**

In `scenes/game.tscn`, add ObstacleSpawner under World:
```
World (Node2D)
├── GroundManager (Node2D)
└── ObstacleSpawner (Node2D)  ← attach obstacle_spawner.gd
```

Set the `obstacle_scene` export to `scenes/obstacle.tscn` in the Inspector.

In world_scroller.gd, connect to GameManager:
```gdscript
func _ready() -> void:
    GameManager.game_over.connect(stop)
```

Auto-start the game for now — add to game.tscn root script or `_ready()`:
```gdscript
func _ready() -> void:
    GameManager.start_game()
```

**Step 7: Verify**

Press F5. Expected:
- Ground scrolls
- Red rectangles (obstacles) spawn from the right at varying intervals
- Some at ground level, some at aerial level
- Running into a ground obstacle stops the game (world stops scrolling)
- Jumping over obstacles works

**Step 8: Commit**

```bash
git add scenes/obstacle.tscn scripts/obstacle.gd scripts/obstacle_spawner.gd scripts/game_manager.gd scripts/player.gd scenes/player.tscn scenes/game.tscn
git commit -m "feat: obstacle spawning and collision-based game over"
```

---

## Task 6: Coins & Scoring

**Goal:** Spawn collectible coins, track score (distance + coins), display on screen.

**Files:**
- Create: `scenes/coin.tscn`
- Create: `scripts/coin.gd`
- Create: `scripts/coin_spawner.gd`
- Modify: `scripts/game_manager.gd` (score tracking)
- Create: `scripts/score_ui.gd`
- Modify: `scenes/game.tscn` (add CoinSpawner + UI)

**Step 1: Create Coin scene**

```
Coin (Area2D)
├── Sprite2D (or ColorRect — yellow circle, 20x20)
├── CollisionShape2D (CircleShape2D, radius 10)
```

Save as `scenes/coin.tscn`.

**Step 2: Write coin.gd**

```gdscript
extends Area2D

func _ready() -> void:
    add_to_group("coins")

func scroll(amount: float) -> void:
    position.x -= amount

func is_off_screen() -> bool:
    return position.x < -50

func collect() -> void:
    queue_free()
```

**Step 3: Write coin_spawner.gd**

```gdscript
extends Node2D

@export var coin_scene: PackedScene
@export var min_gap: float = 200.0
@export var max_gap: float = 400.0
@export var coin_y_min: float = 300.0
@export var coin_y_max: float = 480.0

var _distance_since_last: float = 0.0
var _next_spawn_distance: float = 0.0
var _coins: Array[Node2D] = []
var _is_active: bool = true

func _ready() -> void:
    _next_spawn_distance = randf_range(min_gap, max_gap)

func scroll(amount: float) -> void:
    if not _is_active:
        return

    _distance_since_last += amount

    var to_remove: Array[int] = []
    for i in _coins.size():
        _coins[i].scroll(amount)
        if _coins[i].is_off_screen():
            to_remove.append(i)

    for i in range(to_remove.size() - 1, -1, -1):
        _coins[to_remove[i]].queue_free()
        _coins.remove_at(to_remove[i])

    if _distance_since_last >= _next_spawn_distance:
        _spawn_coin()
        _distance_since_last = 0.0
        _next_spawn_distance = randf_range(min_gap, max_gap)

func _spawn_coin() -> void:
    var coin: Area2D = coin_scene.instantiate()
    coin.position = Vector2(
        get_viewport_rect().size.x + 50,
        randf_range(coin_y_min, coin_y_max)
    )
    _coins.append(coin)
    add_child(coin)

func stop() -> void:
    _is_active = false
```

**Step 4: Detect coin collection in player.gd**

Update `_on_hitbox_area_entered`:

```gdscript
func _on_hitbox_area_entered(area: Area2D) -> void:
    if area.is_in_group("obstacles"):
        _die()
    elif area.is_in_group("coins"):
        area.collect()
        GameManager.add_coin()
```

**Step 5: Update game_manager.gd with scoring**

```gdscript
extends Node

signal game_over
signal game_started
signal score_changed(new_score: int)

var is_playing: bool = false
var score: int = 0
var coin_value: int = 10
var _distance: float = 0.0

func _process(delta: float) -> void:
    if is_playing:
        _distance += delta * 100.0  # ~100 points per second
        var new_score: int = int(_distance)
        if new_score != score:
            score = new_score
            score_changed.emit(score)

func start_game() -> void:
    score = 0
    _distance = 0.0
    is_playing = true
    game_started.emit()

func end_game() -> void:
    is_playing = false
    game_over.emit()

func add_coin() -> void:
    _distance += coin_value
```

**Step 6: Create score_ui.gd**

```gdscript
extends Label

func _ready() -> void:
    GameManager.score_changed.connect(_on_score_changed)
    text = "0"

func _on_score_changed(new_score: int) -> void:
    text = str(new_score)
```

In `scenes/game.tscn`, under UI (CanvasLayer):
```
UI (CanvasLayer)
└── ScoreLabel (Label)  ← attach score_ui.gd
    - position: top-left (20, 20)
    - font_size: 48
    - text: "0"
```

**Step 7: Wire CoinSpawner in Game scene**

```
World (Node2D)
├── GroundManager
├── ObstacleSpawner
└── CoinSpawner (Node2D)  ← attach coin_spawner.gd
```

Set `coin_scene` export to `scenes/coin.tscn`.

**Step 8: Verify**

Press F5. Expected:
- Yellow coins appear at varying heights
- Running into coins makes them disappear
- Score increases over time (distance) and jumps when collecting coins
- Score label updates in real-time at top-left

**Step 9: Commit**

```bash
git add scenes/coin.tscn scripts/coin.gd scripts/coin_spawner.gd scripts/score_ui.gd scripts/game_manager.gd scripts/player.gd scenes/game.tscn
git commit -m "feat: coin collectibles and scoring system"
```

---

## Task 7: Zone System (Data-Driven)

**Goal:** Implement the zone manager that changes visual themes and difficulty based on distance.

**Files:**
- Create: `scripts/zone_data.gd` (Resource class for zone definitions)
- Create: `data/zone_safe_plains.tres`
- Create: `data/zone_danger_cave.tres`
- Create: `data/zone_sky_bonus.tres`
- Create: `scripts/zone_manager.gd`
- Modify: `scripts/obstacle_spawner.gd` (use zone params)
- Modify: `scripts/coin_spawner.gd` (use zone params)
- Modify: `scripts/world_scroller.gd` (speed modifier)

**Step 1: Create ZoneData Resource**

```gdscript
# scripts/zone_data.gd
class_name ZoneData
extends Resource

@export var zone_name: String = ""
@export var ground_color: Color = Color.DARK_GREEN
@export var bg_color: Color = Color.CORNFLOWER_BLUE
@export var obstacle_min_gap: float = 400.0
@export var obstacle_max_gap: float = 700.0
@export var coin_min_gap: float = 200.0
@export var coin_max_gap: float = 400.0
@export var speed_modifier: float = 1.0
@export var obstacle_color: Color = Color.RED
@export var duration_distance: float = 2000.0  # how long this zone lasts
```

**Step 2: Create zone resource files**

In Godot editor: Resource → New Resource → ZoneData → save as `.tres` files in `data/`.

Safe Plains:
- zone_name: "Safe Plains"
- ground_color: dark green
- bg_color: cornflower blue
- obstacle_min_gap: 500, max: 800
- coin_min_gap: 150, max: 300
- speed_modifier: 1.0
- obstacle_color: brown
- duration_distance: 2000

Danger Cave:
- zone_name: "Danger Cave"
- ground_color: dark gray
- bg_color: dark slate gray
- obstacle_min_gap: 250, max: 450
- coin_min_gap: 400, max: 600
- speed_modifier: 1.3
- obstacle_color: dark red
- duration_distance: 1500

Sky Bonus:
- zone_name: "Sky Bonus"
- ground_color: white
- bg_color: orange-red (sunset)
- obstacle_min_gap: 350, max: 550
- coin_min_gap: 100, max: 200
- speed_modifier: 1.1
- obstacle_color: yellow
- duration_distance: 1000

**Step 3: Write zone_manager.gd**

```gdscript
extends Node

signal zone_changed(zone: ZoneData)

@export var zones_safe: Array[ZoneData] = []
@export var zones_danger: Array[ZoneData] = []
@export var zones_bonus: Array[ZoneData] = []

var current_zone: ZoneData
var _distance_in_zone: float = 0.0
var _total_distance: float = 0.0
var _zone_index: int = 0  # alternates safe/danger/bonus

func _ready() -> void:
    if zones_safe.size() > 0:
        _set_zone(zones_safe[0])

func update_distance(amount: float) -> void:
    _distance_in_zone += amount
    _total_distance += amount

    if current_zone and _distance_in_zone >= current_zone.duration_distance:
        _next_zone()

func _next_zone() -> void:
    _distance_in_zone = 0.0
    _zone_index += 1

    var cycle: int = _zone_index % 3
    match cycle:
        0: _set_zone(zones_safe.pick_random())
        1: _set_zone(zones_danger.pick_random())
        2: _set_zone(zones_bonus.pick_random())

func _set_zone(zone: ZoneData) -> void:
    current_zone = zone
    zone_changed.emit(zone)
```

**Step 4: Connect zone changes to spawners and visuals**

In world_scroller.gd, listen for zone changes and apply speed modifier:
```gdscript
var _base_speed: float = 300.0

func _ready() -> void:
    GameManager.game_over.connect(stop)
    var zone_mgr = get_node_or_null("../ZoneManager")
    if zone_mgr:
        zone_mgr.zone_changed.connect(_on_zone_changed)

func _on_zone_changed(zone: ZoneData) -> void:
    scroll_speed = _base_speed * zone.speed_modifier
```

Update obstacle_spawner.gd to use zone params:
```gdscript
func apply_zone(zone: ZoneData) -> void:
    min_gap = zone.obstacle_min_gap
    max_gap = zone.obstacle_max_gap
    # Update obstacle visuals for next spawn
```

Same for coin_spawner.gd.

**Step 5: Wire ZoneManager in Game scene**

```
Game (Node2D)
├── ZoneManager (Node)  ← attach zone_manager.gd, assign zone resources
├── ParallaxBackground
├── Ground
├── World
├── Player
└── UI
```

Add a small script to Game root that calls `zone_manager.update_distance()` each frame.

**Step 6: Verify**

Press F5. Expected:
- Game starts in Safe Plains (green ground, blue sky)
- After ~2000 distance, transitions to Danger Cave (gray, faster, more obstacles)
- Then Sky Bonus (white/sunset, lots of coins)
- Cycles continue

**Step 7: Commit**

```bash
git add scripts/zone_data.gd scripts/zone_manager.gd data/ scripts/world_scroller.gd scripts/obstacle_spawner.gd scripts/coin_spawner.gd scenes/game.tscn
git commit -m "feat: data-driven zone system with themed difficulty"
```

---

## Task 8: Crouch Mechanic (Collision Box Shrink)

**Goal:** When crouching, shrink the player's collision box so they can slide under aerial obstacles.

**Files:**
- Modify: `scripts/player.gd`
- Modify: `scenes/player.tscn` (collision shapes)

**Step 1: Set up two collision shapes**

In `scenes/player.tscn`, rename existing CollisionShape2D and HitboxArea CollisionShape2D:
- `StandingCollision` — full height (28x56)
- `CrouchingCollision` — half height (28x28), disabled by default

Same for HitboxArea:
- `HitboxStanding` — full height
- `HitboxCrouching` — half height, disabled

**Step 2: Update player.gd crouch logic**

```gdscript
const CROUCH_DURATION: float = 0.5  # seconds

var _crouch_timer: float = 0.0

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += GRAVITY * delta

    # Crouch timer
    if _is_crouching:
        _crouch_timer -= delta
        if _crouch_timer <= 0:
            _stand_up()

    if Input.is_action_just_pressed("jump") and is_on_floor():
        _jump()
    if Input.is_action_just_pressed("crouch") and is_on_floor():
        _crouch()

    move_and_slide()

func _crouch() -> void:
    if is_on_floor() and not _is_crouching:
        _is_crouching = true
        _crouch_timer = CROUCH_DURATION
        $CollisionStanding.disabled = true
        $CollisionCrouching.disabled = false
        $HitboxArea/HitboxStanding.disabled = true
        $HitboxArea/HitboxCrouching.disabled = false
        # Visual: squash the sprite
        $Sprite2D.scale.y = 0.5
        $Sprite2D.position.y += 14  # offset to stay on ground

func _stand_up() -> void:
    _is_crouching = false
    $CollisionStanding.disabled = false
    $CollisionCrouching.disabled = true
    $HitboxArea/HitboxStanding.disabled = false
    $HitboxArea/HitboxCrouching.disabled = true
    $Sprite2D.scale.y = 1.0
    $Sprite2D.position.y -= 14
```

**Step 3: Verify**

Press F5. Expected:
- Press S to crouch — player visually squashes
- Aerial obstacles pass overhead while crouching
- After 0.5s, player stands back up automatically
- Ground obstacles still kill when crouching (different Y position)

**Step 4: Commit**

```bash
git add scripts/player.gd scenes/player.tscn
git commit -m "feat: crouch mechanic with collision box switching"
```

---

## Task 9: Main Menu & Game Over Screens

**Goal:** Add functional menu and game over screens with buttons.

**Files:**
- Create: `scenes/main_menu.tscn`
- Create: `scripts/main_menu.gd`
- Create: `scenes/game_over.tscn`
- Create: `scripts/game_over.gd`
- Modify: `scripts/game_manager.gd` (high score + scene transitions)

**Step 1: Create Main Menu scene**

```
MainMenu (Control — full rect)
├── VBoxContainer (centered)
│   ├── TitleLabel ("DASH RUNNER", font_size 72)
│   ├── PlayButton (Button, "PLAY")
│   └── HighScoreLabel ("High Score: 0")
```

Save as `scenes/main_menu.tscn`.

**Step 2: Write main_menu.gd**

```gdscript
extends Control

func _ready() -> void:
    $VBoxContainer/HighScoreLabel.text = "High Score: %d" % GameManager.get_high_score()
    $VBoxContainer/PlayButton.pressed.connect(_on_play)

func _on_play() -> void:
    get_tree().change_scene_to_file("res://scenes/game.tscn")
```

**Step 3: Create Game Over scene**

```
GameOverScreen (Control — full rect)
├── Panel (semi-transparent background)
│   └── VBoxContainer (centered)
│       ├── GameOverLabel ("GAME OVER", font_size 60)
│       ├── ScoreLabel ("Score: 0")
│       ├── HighScoreLabel ("High Score: 0")
│       ├── RetryButton (Button, "RETRY")
│       └── MenuButton (Button, "MENU")
```

Save as `scenes/game_over.tscn`.

**Step 4: Write game_over.gd**

```gdscript
extends Control

func _ready() -> void:
    $Panel/VBoxContainer/ScoreLabel.text = "Score: %d" % GameManager.score

    var high = GameManager.get_high_score()
    var is_new = GameManager.score > high
    if is_new:
        GameManager.save_high_score()
        high = GameManager.score

    var hs_text = "High Score: %d" % high
    if is_new:
        hs_text += " NEW!"
    $Panel/VBoxContainer/HighScoreLabel.text = hs_text

    $Panel/VBoxContainer/RetryButton.pressed.connect(_on_retry)
    $Panel/VBoxContainer/MenuButton.pressed.connect(_on_menu)

func _on_retry() -> void:
    get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_menu() -> void:
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
```

**Step 5: Add high score persistence to game_manager.gd**

```gdscript
const SAVE_PATH: String = "user://highscore.save"

func get_high_score() -> int:
    if not FileAccess.file_exists(SAVE_PATH):
        return 0
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    return file.get_32()

func save_high_score() -> void:
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    file.store_32(score)
```

**Step 6: Connect game over flow**

In game.tscn root script, listen for game_over and show the GameOverScreen:

```gdscript
@onready var game_over_scene: PackedScene = preload("res://scenes/game_over.tscn")

func _ready() -> void:
    GameManager.start_game()
    GameManager.game_over.connect(_on_game_over)

func _on_game_over() -> void:
    var screen = game_over_scene.instantiate()
    $UI.add_child(screen)
```

Set main scene to `scenes/main_menu.tscn` in Project Settings.

**Step 7: Verify**

Press F5. Expected:
- Main menu appears with title, play button, high score
- Click Play → game starts
- Die → Game Over screen appears with score
- Click Retry → game restarts
- Click Menu → back to main menu
- High score persists between sessions

**Step 8: Commit**

```bash
git add scenes/main_menu.tscn scripts/main_menu.gd scenes/game_over.tscn scripts/game_over.gd scripts/game_manager.gd scenes/game.tscn
git commit -m "feat: main menu and game over screens with high score persistence"
```

---

## Task 10: Difficulty Progression

**Goal:** Gradually increase speed over time so the game gets harder.

**Files:**
- Modify: `scripts/world_scroller.gd`
- Modify: `scenes/game.tscn` (game root script)

**Step 1: Add speed ramp to game root script**

```gdscript
const SPEED_INCREASE: float = 10.0      # pixels/sec added
const SPEED_INTERVAL: float = 10.0      # every 10 seconds
const MAX_SPEED: float = 800.0

var _speed_timer: float = 0.0

func _process(delta: float) -> void:
    if GameManager.is_playing:
        _speed_timer += delta
        if _speed_timer >= SPEED_INTERVAL:
            _speed_timer = 0.0
            var world = $World as Node2D
            if world.has_method("increase_speed"):
                world.increase_speed(SPEED_INCREASE)
```

Update world_scroller.gd `increase_speed()`:
```gdscript
func increase_speed(amount: float) -> void:
    _base_speed = min(_base_speed + amount, MAX_SPEED)
    scroll_speed = _base_speed * _current_speed_modifier
```

**Step 2: Verify**

Press F5. Play for 30+ seconds. Expected:
- Game noticeably faster at 30s than at start
- Obstacle spacing feels tighter (natural consequence of speed)
- Game becomes challenging but not impossible

**Step 3: Commit**

```bash
git add scripts/world_scroller.gd scenes/game.tscn
git commit -m "feat: progressive difficulty with speed ramp"
```

---

## Task 11: Player Animations (Placeholder)

**Goal:** Add basic visual feedback for run/jump/crouch/die states using sprite manipulation (no sprite sheets needed yet).

**Files:**
- Modify: `scripts/player.gd` (state machine for animations)
- Modify: `scenes/player.tscn` (AnimationPlayer)

**Step 1: Add AnimationPlayer to Player scene**

In `scenes/player.tscn`, add an `AnimationPlayer` node.

Create animations using the ColorRect placeholder:
- **run**: subtle bounce (y oscillation, 0.4s loop)
- **jump**: stretch vertically (scale.y = 1.2, scale.x = 0.8)
- **crouch**: squash (handled by code already)
- **die**: flash red, rotate, fall off screen

**Step 2: Add state machine to player.gd**

```gdscript
enum State { RUNNING, JUMPING, CROUCHING, DEAD }
var _state: State = State.RUNNING

func _update_animation() -> void:
    match _state:
        State.RUNNING:
            $AnimationPlayer.play("run")
        State.JUMPING:
            $AnimationPlayer.play("jump")
        State.CROUCHING:
            $AnimationPlayer.play("crouch")
        State.DEAD:
            $AnimationPlayer.play("die")
```

Call `_update_animation()` when state changes (in `_jump()`, `_crouch()`, `_stand_up()`, `_die()`).

**Step 3: Verify**

Press F5. Expected:
- Player bounces slightly while running
- Stretches when jumping
- Squashes when crouching
- Flashes/rotates when dying

**Step 4: Commit**

```bash
git add scripts/player.gd scenes/player.tscn
git commit -m "feat: placeholder player animations with state machine"
```

---

## Task 12: Replace Placeholders with Kenney Assets

**Goal:** Swap colored rectangles with actual pixel art from the Kenney pack.

**Files:**
- Add: `assets/kenney/` (downloaded sprites)
- Modify: `scenes/player.tscn` (swap ColorRect → Sprite2D with texture)
- Modify: `scenes/obstacle.tscn` (swap to sprite)
- Modify: `scenes/coin.tscn` (swap to sprite)
- Modify: ground tiles

**Step 1: Download and import Kenney assets**

Download "Pixel Platformer" from kenney.nl. Extract to `assets/kenney/`.

**Step 2: Replace player sprite**

In `scenes/player.tscn`:
- Remove ColorRect
- Set Sprite2D texture to Kenney character sprite
- Adjust CollisionShape2D to match new sprite dimensions

**Step 3: Replace obstacle sprites**

Create 2 variants:
- Ground obstacle: use crate/rock sprite
- Aerial obstacle: use spike/stalactite sprite (positioned higher)

**Step 4: Replace coin sprite**

Use Kenney coin sprite. Add a simple rotation animation in AnimationPlayer.

**Step 5: Replace ground tiles**

Use Kenney tileset for ground. Update GroundManager to use `Sprite2D` with the tileset texture.

**Step 6: Verify**

Press F5. Expected:
- Game looks like a proper pixel art platformer
- All collisions still work correctly
- Animations play properly with new sprites

**Step 7: Commit**

```bash
git add assets/ scenes/ scripts/
git commit -m "feat: replace placeholders with Kenney pixel art assets"
```

---

## Task 13: Android Export Setup

**Goal:** Configure Godot to export an APK for Android.

**Step 1: Install Android build tools**

In Godot: Editor → Editor Settings → Export → Android:
- Set Java SDK path (install JDK 17 if needed)
- Set Android SDK path (install via Android Studio or command line tools)
- Generate debug keystore if not present

**Step 2: Add Android export preset**

Project → Export → Add → Android:
- Package name: `com.dashrunner.game`
- Version: `1.0.0`
- Min SDK: 24 (Android 7.0)
- Target SDK: 33
- Screen orientation: Landscape

**Step 3: Export debug APK**

Click "Export Project" → save as `build/dash-runner-debug.apk`

**Step 4: Verify**

Install APK on Android device or emulator:
```bash
adb install build/dash-runner-debug.apk
```

Expected:
- Game opens in landscape
- Swipe controls work on touchscreen
- Performance is smooth (60fps target)

**Step 5: Commit**

```bash
git add export_presets.cfg
git commit -m "feat: Android export configuration"
```

---

## Summary

| Task | Description | Key Learning |
|------|-------------|--------------|
| 1 | Project setup | Godot editor, scenes, project settings |
| 2 | Player + gravity | CharacterBody2D, physics, collision |
| 3 | Swipe input | InputMap, touch events, signals |
| 4 | World scrolling | Infinite scroll pattern, parallax |
| 5 | Obstacles + death | Area2D, groups, game state |
| 6 | Coins + score | Collectibles, UI, signals |
| 7 | Zone system | Resources, data-driven design |
| 8 | Crouch mechanic | Collision shape swapping |
| 9 | Menu screens | Scene transitions, file persistence |
| 10 | Difficulty ramp | Progressive challenge |
| 11 | Animations | AnimationPlayer, state machine |
| 12 | Real assets | Sprite integration, tilesets |
| 13 | Android export | Build pipeline, APK generation |

**Estimated tasks: 13 | Each task: 15-30 min | Total: ~5-8 hours of learning**
