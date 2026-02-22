# Multi-Axis Dash Runner Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rebuild Dash Runner as a multi-axis runner with 4 directional levels (Río, Plataforma, Hellevator, Abducción OVNI), XP-based progression, lane system for vertical levels, and teleporter transitions.

**Architecture:** Vector2-based direction system where all core systems (scroller, spawner, player) receive `scroll_direction` and `dodge_direction` from a `LevelData` resource. Level scenes are instantiated dynamically by a persistent `Main` scene. XP persists across sessions and drives difficulty scaling.

**Tech Stack:** Godot 4.6+, GDScript, Kenney Pixel Platformer assets, Android export

**Design doc:** `docs/plans/2026-02-22-multi-axis-redesign-design.md`

**Kenney asset reference:**
- Characters: `assets/kenney/Tiles/Characters/tile_XXXX.png` (18x18px each)
- Background tiles: `assets/kenney/Tiles/Backgrounds/tile_XXXX.png` (18x18px each)
- Full tilemap: `assets/kenney/Tilemap/tilemap.png` (for reference)
- Character tilemap: `assets/kenney/Tilemap/tilemap-characters.png` (for reference)

**Note on testing:** Godot does not have a built-in test runner. Each task includes a "Verify" step where you run the game (F5) or scene (F6) and check expected behavior visually. Print statements are used for logic verification.

---

## Task 1: Clean Up Existing Project

**Goal:** Remove the old single-axis scenes and scripts. Start fresh with the new architecture.

**Files:**
- Delete: `scenes/gane.tscn` (old game scene — note: filename has typo "gane")
- Delete: `scenes/player.tscn` (old player with ColorRect placeholder)
- Delete: `scenes/player.gd` (old player script)
- Delete: `scenes/player.gd.uid` (orphaned UID file)

**Step 1: Delete old files**

Delete the following files from the Godot FileSystem dock or filesystem:
- `scenes/gane.tscn`
- `scenes/player.tscn`
- `scenes/player.gd`
- `scenes/player.gd.uid`

**Step 2: Verify project still opens**

Open Godot. The project will warn about missing main scene. That's expected — we'll set a new one later.

**Step 3: Commit**

```bash
git add -A
git commit -m "chore: remove old single-axis scenes and scripts"
```

---

## Task 2: LevelData Resource Class

**Goal:** Create the `LevelData` resource class that defines all parameters for a level.

**Files:**
- Create: `scripts/level_data.gd`

**Step 1: Create the resource script**

Create `scripts/level_data.gd`:

```gdscript
class_name LevelData
extends Resource

@export var level_name: String = ""
@export var scroll_direction: Vector2 = Vector2(1, 0)
@export var dodge_direction: Vector2 = Vector2(0, -1)
@export var base_speed: float = 300.0
@export var base_distance: float = 2000.0
@export var distance_scale_per_xp: float = 5.0
@export var gravity_enabled: bool = true
@export var gravity_direction: Vector2 = Vector2(0, 1)
@export var coin_frequency: float = 200.0
@export var coin_value: int = 10
@export var obstacle_min_gap: float = 400.0
@export var obstacle_max_gap: float = 700.0
@export var ground_color: Color = Color.DARK_GREEN
@export var bg_color: Color = Color.CORNFLOWER_BLUE
@export var obstacle_color: Color = Color.RED
@export var level_complete_bonus: int = 50

## Returns true if this is a horizontal-scrolling level
func is_horizontal() -> bool:
	return scroll_direction.x != 0.0

## Returns the spawn edge position (where new objects appear)
func get_spawn_offset(viewport_size: Vector2) -> Vector2:
	if scroll_direction == Vector2(1, 0):
		return Vector2(viewport_size.x + 100, 0)
	elif scroll_direction == Vector2(-1, 0):
		return Vector2(-100, 0)
	elif scroll_direction == Vector2(0, 1):
		return Vector2(0, viewport_size.y + 100)
	elif scroll_direction == Vector2(0, -1):
		return Vector2(0, -100)
	return Vector2.ZERO

## Returns the destroy threshold (where objects get cleaned up)
func get_destroy_threshold(viewport_size: Vector2) -> float:
	if scroll_direction == Vector2(1, 0):
		return -100.0
	elif scroll_direction == Vector2(-1, 0):
		return viewport_size.x + 100.0
	elif scroll_direction == Vector2(0, 1):
		return -100.0
	elif scroll_direction == Vector2(0, -1):
		return viewport_size.y + 100.0
	return 0.0

## Returns which axis to check for destroy threshold
func get_scroll_axis() -> String:
	if scroll_direction.x != 0.0:
		return "x"
	return "y"
```

**Step 2: Verify resource compiles**

Open Godot. Check Output panel for errors. The script should compile without issues. You can verify by going to Inspector → New Resource → search for "LevelData" — it should appear.

**Step 3: Commit**

```bash
git add scripts/level_data.gd
git commit -m "feat: add LevelData resource class for level configuration"
```

---

## Task 3: Create the 4 Level Data Files

**Goal:** Create `.tres` resource files for Río, Plataforma, Hellevator, and Abducción OVNI.

**Files:**
- Create: `data/level_rio.tres`
- Create: `data/level_plataforma.tres`
- Create: `data/level_hellevator.tres`
- Create: `data/level_abduccion.tres`

**Step 1: Create Río level data**

In Godot editor: FileSystem → right-click `data/` → New Resource → search "LevelData" → Create.

Set these values in the Inspector:
- `level_name`: `Río`
- `scroll_direction`: `Vector2(1, 0)`
- `dodge_direction`: `Vector2(0, -1)`
- `base_speed`: `300.0`
- `base_distance`: `2000.0`
- `distance_scale_per_xp`: `5.0`
- `gravity_enabled`: `true`
- `gravity_direction`: `Vector2(0, 1)`
- `coin_frequency`: `200.0`
- `coin_value`: `10`
- `obstacle_min_gap`: `500.0`
- `obstacle_max_gap`: `800.0`
- `ground_color`: `Color(0.18, 0.55, 0.18)` (forest green)
- `bg_color`: `Color(0.39, 0.58, 0.93)` (cornflower blue)
- `obstacle_color`: `Color(0.55, 0.27, 0.07)` (brown)
- `level_complete_bonus`: `50`

Save as `data/level_rio.tres`.

**Step 2: Create Plataforma level data**

New Resource → LevelData:
- `level_name`: `Plataforma`
- `scroll_direction`: `Vector2(-1, 0)`
- `dodge_direction`: `Vector2(0, -1)`
- `base_speed`: `280.0`
- `base_distance`: `1800.0`
- `distance_scale_per_xp`: `4.0`
- `gravity_enabled`: `true`
- `gravity_direction`: `Vector2(0, 1)`
- `coin_frequency`: `250.0`
- `coin_value`: `10`
- `obstacle_min_gap`: `400.0`
- `obstacle_max_gap`: `650.0`
- `ground_color`: `Color(0.4, 0.4, 0.4)` (gray)
- `bg_color`: `Color(0.18, 0.20, 0.25)` (dark slate)
- `obstacle_color`: `Color(0.6, 0.1, 0.1)` (dark red)
- `level_complete_bonus`: `50`

Save as `data/level_plataforma.tres`.

**Step 3: Create Hellevator level data**

New Resource → LevelData:
- `level_name`: `Hellevator`
- `scroll_direction`: `Vector2(0, 1)`
- `dodge_direction`: `Vector2(1, 0)`
- `base_speed`: `350.0`
- `base_distance`: `2500.0`
- `distance_scale_per_xp`: `6.0`
- `gravity_enabled`: `false`
- `gravity_direction`: `Vector2(0, 0)`
- `coin_frequency`: `180.0`
- `coin_value`: `15`
- `obstacle_min_gap`: `350.0`
- `obstacle_max_gap`: `600.0`
- `ground_color`: `Color(0.3, 0.15, 0.1)` (dark brown)
- `bg_color`: `Color(0.15, 0.05, 0.0)` (near black/lava)
- `obstacle_color`: `Color(0.9, 0.3, 0.0)` (orange/fire)
- `level_complete_bonus`: `75`

Save as `data/level_hellevator.tres`.

**Step 4: Create Abducción OVNI level data**

New Resource → LevelData:
- `level_name`: `Abducción OVNI`
- `scroll_direction`: `Vector2(0, -1)`
- `dodge_direction`: `Vector2(1, 0)`
- `base_speed`: `320.0`
- `base_distance`: `2200.0`
- `distance_scale_per_xp`: `5.5`
- `gravity_enabled`: `false`
- `gravity_direction`: `Vector2(0, 0)`
- `coin_frequency`: `160.0`
- `coin_value`: `12`
- `obstacle_min_gap`: `300.0`
- `obstacle_max_gap`: `550.0`
- `ground_color`: `Color(0.25, 0.25, 0.35)` (dark blue-gray)
- `bg_color`: `Color(0.05, 0.0, 0.15)` (deep night)
- `obstacle_color`: `Color(0.0, 0.9, 0.3)` (alien green)
- `level_complete_bonus`: `60`

Save as `data/level_abduccion.tres`.

**Step 5: Verify all 4 files load**

In Godot, double-click each `.tres` file. The Inspector should show all properties correctly. Verify `level_name` is set for each.

**Step 6: Commit**

```bash
git add data/level_rio.tres data/level_plataforma.tres data/level_hellevator.tres data/level_abduccion.tres
git commit -m "feat: add 4 level data resources (río, plataforma, hellevator, abducción)"
```

---

## Task 4: GameManager Autoload

**Goal:** Create the GameManager singleton that handles XP, game state, and save/load.

**Files:**
- Create: `scripts/game_manager.gd`
- Modify: `project.godot` (register autoload)

**Step 1: Create game_manager.gd**

Create `scripts/game_manager.gd`:

```gdscript
extends Node

signal game_started
signal game_over
signal xp_changed(new_xp: int)
signal level_completed

enum State { MENU, PLAYING, DEAD }

const SAVE_PATH: String = "user://savegame.save"
const DEATH_PENALTY: float = 0.20

var state: State = State.MENU
var total_xp: int = 0
var session_xp: int = 0
var high_score: int = 0
var levels_completed: int = 0

func _ready() -> void:
	load_data()

## Start a new game session
func start_game() -> void:
	session_xp = 0
	state = State.PLAYING
	game_started.emit()

## End the game (player died)
func end_game() -> void:
	state = State.DEAD
	var penalty: int = int(total_xp * DEATH_PENALTY)
	total_xp = max(0, total_xp - penalty)
	if session_xp > high_score:
		high_score = session_xp
	save_data()
	game_over.emit()

## Player collected a coin
func add_xp(value: int) -> void:
	total_xp += value
	session_xp += value
	xp_changed.emit(total_xp)

## Player completed a level (touched teleporter)
func complete_level(bonus: int) -> void:
	total_xp += bonus
	session_xp += bonus
	levels_completed += 1
	xp_changed.emit(total_xp)
	level_completed.emit()

## Get current difficulty level (every 100 XP = 1 level)
func get_difficulty_level() -> int:
	return total_xp / 100

## Calculate level distance based on XP
func calculate_level_distance(base: float, scale: float) -> float:
	return base + (get_difficulty_level() * scale)

## Calculate scroll speed based on XP
func calculate_speed(base: float) -> float:
	return base + (get_difficulty_level() * 15.0)

## Calculate obstacle gap based on XP
func calculate_obstacle_gap(min_gap: float, max_gap: float) -> float:
	var reduction: float = get_difficulty_level() * 10.0
	return max(min_gap, max_gap - reduction)

## Save XP and stats to disk
func save_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var({
			"total_xp": total_xp,
			"high_score": high_score,
			"levels_completed": levels_completed,
		})

## Load XP and stats from disk
func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var data: Variant = file.get_var()
		if data is Dictionary:
			total_xp = data.get("total_xp", 0)
			high_score = data.get("high_score", 0)
			levels_completed = data.get("levels_completed", 0)
```

**Step 2: Register as Autoload**

In Godot: Project → Project Settings → Autoload → Add:
- Path: `res://scripts/game_manager.gd`
- Name: `GameManager`
- Enabled: ✓

**Step 3: Verify autoload works**

Create a temporary scene (any Node2D) with a script:
```gdscript
func _ready():
	print("XP: ", GameManager.total_xp)
	print("Difficulty: ", GameManager.get_difficulty_level())
```
Run with F6. Output panel should show `XP: 0` and `Difficulty: 0`. Delete the temp scene after.

**Step 4: Commit**

```bash
git add scripts/game_manager.gd project.godot
git commit -m "feat: add GameManager autoload with XP persistence and difficulty scaling"
```

---

## Task 5: SwipeDetector Autoload

**Goal:** Create the SwipeDetector singleton that detects swipe in all 4 directions + keyboard fallback.

**Files:**
- Create: `scripts/swipe_detector.gd`
- Modify: `project.godot` (register autoload + InputMap)

**Step 1: Configure InputMap**

In Godot: Project → Project Settings → Input Map → Add these actions:

| Action | Keys |
|--------|------|
| `move_up` | W, Space, Up Arrow |
| `move_down` | S, Down Arrow |
| `move_left` | A, Left Arrow |
| `move_right` | D, Right Arrow |

**Step 2: Create swipe_detector.gd**

Create `scripts/swipe_detector.gd`:

```gdscript
extends Node

signal swiped_up
signal swiped_down
signal swiped_left
signal swiped_right

const SWIPE_THRESHOLD: float = 50.0
const TAP_THRESHOLD: float = 20.0

var _touch_start: Vector2 = Vector2.ZERO
var _touch_start_time: int = 0
var _is_touching: bool = false

func _input(event: InputEvent) -> void:
	# Touch input
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_start = event.position
			_touch_start_time = Time.get_ticks_msec()
			_is_touching = true
		elif _is_touching:
			_process_gesture(event.position)
			_is_touching = false

	# Keyboard fallback
	if event.is_action_pressed("move_up"):
		swiped_up.emit()
	elif event.is_action_pressed("move_down"):
		swiped_down.emit()
	elif event.is_action_pressed("move_left"):
		swiped_left.emit()
	elif event.is_action_pressed("move_right"):
		swiped_right.emit()

func _process_gesture(end_pos: Vector2) -> void:
	var diff: Vector2 = end_pos - _touch_start

	if diff.length() < TAP_THRESHOLD:
		return

	if diff.length() < SWIPE_THRESHOLD:
		return

	# Determine dominant axis
	if abs(diff.x) > abs(diff.y):
		# Horizontal swipe
		if diff.x > 0:
			swiped_right.emit()
		else:
			swiped_left.emit()
	else:
		# Vertical swipe
		if diff.y < 0:
			swiped_up.emit()
		else:
			swiped_down.emit()
```

**Step 3: Register as Autoload**

Project → Project Settings → Autoload → Add:
- Path: `res://scripts/swipe_detector.gd`
- Name: `SwipeDetector`
- Enabled: ✓

**Step 4: Verify with temp test**

Create a temp scene with script:
```gdscript
func _ready():
	SwipeDetector.swiped_up.connect(func(): print("UP"))
	SwipeDetector.swiped_down.connect(func(): print("DOWN"))
	SwipeDetector.swiped_left.connect(func(): print("LEFT"))
	SwipeDetector.swiped_right.connect(func(): print("RIGHT"))
```
Run F6. Press W/S/A/D — should print corresponding direction. Delete temp scene after.

**Step 5: Commit**

```bash
git add scripts/swipe_detector.gd project.godot
git commit -m "feat: add SwipeDetector autoload with 4-direction swipe and keyboard"
```

---

## Task 6: Player Scene with Kenney Sprite

**Goal:** Create the player scene with Kenney character sprite, collision shapes for both standing and crouching, and the hitbox Area2D for obstacle/coin detection.

**Files:**
- Create: `scenes/player.tscn`
- Create: `scripts/player.gd`

**Step 1: Build Player scene tree**

Create a new scene in Godot with root `CharacterBody2D`, name it "Player".

Add the following children:
```
Player (CharacterBody2D)
├── Sprite2D                    (Kenney character: tile_0000.png)
├── StandingCollision (CollisionShape2D)  (RectangleShape2D 14x18 — full height)
├── CrouchingCollision (CollisionShape2D) (RectangleShape2D 14x9 — half height, DISABLED)
├── HitboxArea (Area2D)
│   ├── HitboxStanding (CollisionShape2D) (RectangleShape2D 14x18, DISABLED=false)
│   └── HitboxCrouching (CollisionShape2D) (RectangleShape2D 14x9, DISABLED=true)
```

For Sprite2D:
- Texture: `res://assets/kenney/Tiles/Characters/tile_0000.png`
- The sprite is 18x18px. Enable `Texture → Filter: Nearest` in Project Settings (for pixel art).

For StandingCollision:
- Shape: RectangleShape2D, size `Vector2(14, 18)`
- Position: `Vector2(0, 0)` (centered on sprite)

For CrouchingCollision:
- Shape: RectangleShape2D, size `Vector2(14, 9)`
- Position: `Vector2(0, 4.5)` (lower half)
- **Disabled: true**

For HitboxArea:
- Set collision layer and mask as needed (layer 2 for player hitbox)

Save as `scenes/player.tscn`.

**Step 2: Set pixel art rendering**

In Project → Project Settings:
- `rendering/textures/canvas_textures/default_texture_filter` = `Nearest`

This ensures all pixel art renders crisp without blur.

**Step 3: Write player.gd**

Create `scripts/player.gd` and attach to the Player root node:

```gdscript
extends CharacterBody2D

const GRAVITY_FORCE: float = 1200.0
const JUMP_VELOCITY: float = -500.0
const CROUCH_DURATION: float = 0.5
const LANE_POSITIONS: Array[float] = [-150.0, 0.0, 150.0]
const LANE_TWEEN_SPEED: float = 0.15

enum Mode { HORIZONTAL, VERTICAL }
enum State { RUNNING, JUMPING, CROUCHING, DODGING, DEAD }

var mode: Mode = Mode.HORIZONTAL
var current_state: State = State.RUNNING
var level_data: LevelData

var _crouch_timer: float = 0.0
var _current_lane: int = 1  # center lane (index into LANE_POSITIONS)
var _dodge_axis_position: float = 0.0

func configure(data: LevelData) -> void:
	level_data = data
	if data.is_horizontal():
		mode = Mode.HORIZONTAL
		_connect_horizontal_input()
	else:
		mode = Mode.VERTICAL
		_connect_vertical_input()

func _connect_horizontal_input() -> void:
	SwipeDetector.swiped_up.connect(_on_dodge_positive)
	SwipeDetector.swiped_down.connect(_on_dodge_negative)

func _connect_vertical_input() -> void:
	SwipeDetector.swiped_right.connect(_on_dodge_positive)
	SwipeDetector.swiped_left.connect(_on_dodge_negative)

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	match mode:
		Mode.HORIZONTAL:
			_process_horizontal(delta)
		Mode.VERTICAL:
			_process_vertical(delta)

	move_and_slide()

func _process_horizontal(delta: float) -> void:
	# Apply gravity
	if level_data.gravity_enabled and not is_on_floor():
		velocity.y += GRAVITY_FORCE * delta

	# Crouch timer
	if current_state == State.CROUCHING:
		_crouch_timer -= delta
		if _crouch_timer <= 0:
			_stand_up()

	# Landing detection
	if current_state == State.JUMPING and is_on_floor():
		current_state = State.RUNNING

func _process_vertical(_delta: float) -> void:
	# No gravity in vertical mode — velocity stays zero on dodge axis
	# Lane position is handled by tween in _move_to_lane()
	pass

func _on_dodge_positive() -> void:
	if current_state == State.DEAD:
		return
	match mode:
		Mode.HORIZONTAL:
			_jump()
		Mode.VERTICAL:
			_move_to_lane(_current_lane + 1)

func _on_dodge_negative() -> void:
	if current_state == State.DEAD:
		return
	match mode:
		Mode.HORIZONTAL:
			_crouch()
		Mode.VERTICAL:
			_move_to_lane(_current_lane - 1)

func _jump() -> void:
	if is_on_floor() and current_state != State.CROUCHING:
		velocity.y = JUMP_VELOCITY
		current_state = State.JUMPING

func _crouch() -> void:
	if is_on_floor() and current_state == State.RUNNING:
		current_state = State.CROUCHING
		_crouch_timer = CROUCH_DURATION
		$StandingCollision.disabled = true
		$CrouchingCollision.disabled = false
		$HitboxArea/HitboxStanding.disabled = true
		$HitboxArea/HitboxCrouching.disabled = false

func _stand_up() -> void:
	current_state = State.RUNNING
	$StandingCollision.disabled = false
	$CrouchingCollision.disabled = true
	$HitboxArea/HitboxStanding.disabled = false
	$HitboxArea/HitboxCrouching.disabled = true

func _move_to_lane(target_lane: int) -> void:
	target_lane = clampi(target_lane, 0, LANE_POSITIONS.size() - 1)
	if target_lane == _current_lane:
		return
	_current_lane = target_lane
	current_state = State.DODGING

	var target_x: float = LANE_POSITIONS[_current_lane]
	var tween := create_tween()
	tween.tween_property(self, "position:x", target_x, LANE_TWEEN_SPEED)
	tween.tween_callback(func(): current_state = State.RUNNING)

func die() -> void:
	if current_state == State.DEAD:
		return
	current_state = State.DEAD
	set_physics_process(false)
	# Disconnect all swipe signals
	var connections := SwipeDetector.swiped_up.get_connections()
	for conn in connections:
		if conn.callable.get_object() == self:
			SwipeDetector.swiped_up.disconnect(conn.callable)
	connections = SwipeDetector.swiped_down.get_connections()
	for conn in connections:
		if conn.callable.get_object() == self:
			SwipeDetector.swiped_down.disconnect(conn.callable)
	connections = SwipeDetector.swiped_left.get_connections()
	for conn in connections:
		if conn.callable.get_object() == self:
			SwipeDetector.swiped_left.disconnect(conn.callable)
	connections = SwipeDetector.swiped_right.get_connections()
	for conn in connections:
		if conn.callable.get_object() == self:
			SwipeDetector.swiped_right.disconnect(conn.callable)
	GameManager.end_game()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacles"):
		die()
	elif area.is_in_group("coins"):
		area.collect()
		GameManager.add_xp(level_data.coin_value)
```

**Step 4: Connect HitboxArea signal**

In the Player scene, select HitboxArea → Node tab → Signals → `area_entered` → Connect to Player root → method `_on_hitbox_area_entered`.

**Step 5: Save and verify**

Save `scenes/player.tscn`. Open it with F6. Expected:
- Player (Kenney sprite) appears
- Falls due to gravity (no floor in standalone scene — expected)
- No errors in Output

**Step 6: Commit**

```bash
git add scenes/player.tscn scripts/player.gd
git commit -m "feat: add Player scene with dual-mode input (horizontal/vertical)"
```

---

## Task 7: WorldScroller

**Goal:** Create the world scroller that moves children in the direction defined by LevelData, tracking distance traveled.

**Files:**
- Create: `scripts/world_scroller.gd`

**Step 1: Create world_scroller.gd**

```gdscript
extends Node2D

signal distance_updated(total: float)

var scroll_vector: Vector2 = Vector2.ZERO
var current_speed: float = 0.0
var distance_traveled: float = 0.0
var _is_running: bool = false

func configure(data: LevelData) -> void:
	scroll_vector = -data.scroll_direction
	current_speed = GameManager.calculate_speed(data.base_speed)
	distance_traveled = 0.0

func start() -> void:
	_is_running = true

func stop() -> void:
	_is_running = false

func _process(delta: float) -> void:
	if not _is_running:
		return

	var movement: Vector2 = scroll_vector * current_speed * delta
	distance_traveled += current_speed * delta

	for child in get_children():
		if child.has_method("scroll"):
			child.scroll(movement)

	distance_updated.emit(distance_traveled)
```

**Step 2: Commit**

```bash
git add scripts/world_scroller.gd
git commit -m "feat: add WorldScroller with Vector2-based directional scrolling"
```

---

## Task 8: TerrainManager

**Goal:** Create the terrain manager that generates infinite scrolling tiles in the correct axis, recycling them when they go off-screen.

**Files:**
- Create: `scripts/terrain_manager.gd`

**Step 1: Create terrain_manager.gd**

```gdscript
extends Node2D

var _tiles: Array[ColorRect] = []
var _tile_size: float = 0.0
var _scroll_axis: String = "x"
var _level_data: LevelData
var _viewport_size: Vector2

func configure(data: LevelData) -> void:
	_level_data = data
	_viewport_size = get_viewport_rect().size
	_scroll_axis = data.get_scroll_axis()

	# Clear any existing tiles
	for tile in _tiles:
		tile.queue_free()
	_tiles.clear()

	if data.is_horizontal():
		_setup_horizontal_ground()
	else:
		_setup_vertical_walls()

func _setup_horizontal_ground() -> void:
	_tile_size = 128.0
	var ground_y: float = _viewport_size.y - 100.0
	var count: int = ceili(_viewport_size.x / _tile_size) + 3

	for i in count:
		var tile := ColorRect.new()
		tile.size = Vector2(_tile_size, 100.0)
		tile.color = _level_data.ground_color
		tile.position = Vector2(i * _tile_size, ground_y)
		_tiles.append(tile)
		add_child(tile)

func _setup_vertical_walls() -> void:
	_tile_size = 128.0
	var wall_width: float = 60.0
	var count: int = ceili(_viewport_size.y / _tile_size) + 3

	for i in count:
		# Left wall
		var left := ColorRect.new()
		left.size = Vector2(wall_width, _tile_size)
		left.color = _level_data.ground_color
		left.position = Vector2(0, i * _tile_size)
		_tiles.append(left)
		add_child(left)

		# Right wall
		var right := ColorRect.new()
		right.size = Vector2(wall_width, _tile_size)
		right.color = _level_data.ground_color
		right.position = Vector2(_viewport_size.x - wall_width, i * _tile_size)
		_tiles.append(right)
		add_child(right)

func scroll(movement: Vector2) -> void:
	for tile in _tiles:
		tile.position += movement

	_recycle_tiles()

func _recycle_tiles() -> void:
	if _level_data.is_horizontal():
		_recycle_horizontal()
	else:
		_recycle_vertical()

func _recycle_horizontal() -> void:
	var rightmost_x: float = _get_max_position("x")
	for tile in _tiles:
		if tile.position.x < -_tile_size:
			tile.position.x = rightmost_x + _tile_size
		elif tile.position.x > _viewport_size.x + _tile_size:
			var leftmost_x: float = _get_min_position("x")
			tile.position.x = leftmost_x - _tile_size

func _recycle_vertical() -> void:
	var bottommost_y: float = _get_max_position("y")
	for tile in _tiles:
		if tile.position.y < -_tile_size:
			tile.position.y = bottommost_y + _tile_size
		elif tile.position.y > _viewport_size.y + _tile_size:
			var topmost_y: float = _get_min_position("y")
			tile.position.y = topmost_y - _tile_size

func _get_max_position(axis: String) -> float:
	var max_val: float = -INF
	for tile in _tiles:
		var val: float = tile.position.x if axis == "x" else tile.position.y
		if val > max_val:
			max_val = val
	return max_val

func _get_min_position(axis: String) -> float:
	var min_val: float = INF
	for tile in _tiles:
		var val: float = tile.position.x if axis == "x" else tile.position.y
		if val < min_val:
			min_val = val
	return min_val
```

**Step 2: Commit**

```bash
git add scripts/terrain_manager.gd
git commit -m "feat: add TerrainManager with axis-aware infinite tile recycling"
```

---

## Task 9: Obstacle Scene and Spawner

**Goal:** Create the obstacle Area2D scene and the spawner that generates obstacles based on scroll direction and difficulty.

**Files:**
- Create: `scenes/obstacle.tscn`
- Create: `scripts/obstacle.gd`
- Create: `scripts/obstacle_spawner.gd`

**Step 1: Create Obstacle scene**

New scene → Root: `Area2D` → Name: "Obstacle"

```
Obstacle (Area2D)
├── ColorRect               (colored rectangle — size set by spawner)
├── CollisionShape2D         (RectangleShape2D — size set by spawner)
```

For ColorRect: size `Vector2(32, 32)`, color will be set by spawner.
For CollisionShape2D: RectangleShape2D size `Vector2(28, 28)`.

Save as `scenes/obstacle.tscn`.

**Step 2: Write obstacle.gd**

Attach to Obstacle root:

```gdscript
extends Area2D

func _ready() -> void:
	add_to_group("obstacles")

func setup(color: Color, obs_size: Vector2) -> void:
	$ColorRect.color = color
	$ColorRect.size = obs_size
	$ColorRect.position = -obs_size / 2
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.size = obs_size - Vector2(4, 4)
```

**Step 3: Write obstacle_spawner.gd**

Create `scripts/obstacle_spawner.gd`:

```gdscript
extends Node2D

@export var obstacle_scene: PackedScene

var _level_data: LevelData
var _viewport_size: Vector2
var _distance_since_last: float = 0.0
var _next_spawn_distance: float = 0.0
var _obstacles: Array[Area2D] = []
var _is_active: bool = false
var _current_min_gap: float = 400.0
var _current_max_gap: float = 700.0

func configure(data: LevelData) -> void:
	_level_data = data
	_viewport_size = get_viewport_rect().size
	_current_min_gap = GameManager.calculate_obstacle_gap(data.obstacle_min_gap, data.obstacle_max_gap)
	_current_max_gap = data.obstacle_max_gap
	_next_spawn_distance = randf_range(_current_min_gap, _current_max_gap)
	_distance_since_last = 0.0

func start() -> void:
	_is_active = true

func stop() -> void:
	_is_active = false

func scroll(movement: Vector2) -> void:
	if not _is_active:
		return

	_distance_since_last += movement.length()

	# Move existing obstacles
	var to_remove: Array[int] = []
	for i in _obstacles.size():
		_obstacles[i].position += movement
		if _is_off_screen(_obstacles[i]):
			to_remove.append(i)

	# Remove off-screen (reverse order)
	for i in range(to_remove.size() - 1, -1, -1):
		_obstacles[to_remove[i]].queue_free()
		_obstacles.remove_at(to_remove[i])

	# Spawn new
	if _distance_since_last >= _next_spawn_distance:
		_spawn_obstacle()
		_distance_since_last = 0.0
		_next_spawn_distance = randf_range(_current_min_gap, _current_max_gap)

func _spawn_obstacle() -> void:
	if not obstacle_scene:
		return

	var obs: Area2D = obstacle_scene.instantiate()
	var spawn_pos: Vector2 = _calculate_spawn_position()
	obs.position = spawn_pos

	obs.setup(_level_data.obstacle_color, Vector2(32, 32))

	_obstacles.append(obs)
	add_child(obs)

func _calculate_spawn_position() -> Vector2:
	var spawn_offset: Vector2 = _level_data.get_spawn_offset(_viewport_size)

	if _level_data.is_horizontal():
		# Horizontal: spawn at ground or aerial height
		var ground_y: float = _viewport_size.y - 130.0
		var aerial_y: float = _viewport_size.y - 200.0
		var is_aerial: bool = randf() > 0.65
		var y_pos: float = aerial_y if is_aerial else ground_y
		return Vector2(spawn_offset.x, y_pos)
	else:
		# Vertical: spawn in 1-2 of 3 lanes
		var lane_x: float = [-150.0, 0.0, 150.0].pick_random()
		# Center lanes around viewport center
		lane_x += _viewport_size.x / 2.0
		return Vector2(lane_x, spawn_offset.y)

func _is_off_screen(obs: Area2D) -> bool:
	var axis: String = _level_data.get_scroll_axis()
	var threshold: float = _level_data.get_destroy_threshold(_viewport_size)

	if axis == "x":
		if _level_data.scroll_direction.x > 0:
			return obs.position.x < threshold
		else:
			return obs.position.x > threshold
	else:
		if _level_data.scroll_direction.y > 0:
			return obs.position.y < threshold
		else:
			return obs.position.y > threshold
```

**Step 4: Commit**

```bash
git add scenes/obstacle.tscn scripts/obstacle.gd scripts/obstacle_spawner.gd
git commit -m "feat: add Obstacle scene and axis-aware ObstacleSpawner"
```

---

## Task 10: Coin Scene and Spawner

**Goal:** Create the coin collectible and its spawner.

**Files:**
- Create: `scenes/coin.tscn`
- Create: `scripts/coin.gd`
- Create: `scripts/coin_spawner.gd`

**Step 1: Create Coin scene**

New scene → Root: `Area2D` → Name: "Coin"

```
Coin (Area2D)
├── ColorRect               (yellow, 16x16)
├── CollisionShape2D         (CircleShape2D, radius 7)
```

ColorRect: size `Vector2(16, 16)`, position `Vector2(-8, -8)`, color `Color.YELLOW`.
CollisionShape2D: CircleShape2D, radius `7`.

Save as `scenes/coin.tscn`.

**Step 2: Write coin.gd**

```gdscript
extends Area2D

func _ready() -> void:
	add_to_group("coins")

func collect() -> void:
	queue_free()
```

**Step 3: Write coin_spawner.gd**

```gdscript
extends Node2D

@export var coin_scene: PackedScene

var _level_data: LevelData
var _viewport_size: Vector2
var _distance_since_last: float = 0.0
var _next_spawn_distance: float = 0.0
var _coins: Array[Area2D] = []
var _is_active: bool = false

func configure(data: LevelData) -> void:
	_level_data = data
	_viewport_size = get_viewport_rect().size
	_next_spawn_distance = randf_range(data.coin_frequency * 0.5, data.coin_frequency * 1.5)
	_distance_since_last = 0.0

func start() -> void:
	_is_active = true

func stop() -> void:
	_is_active = false

func scroll(movement: Vector2) -> void:
	if not _is_active:
		return

	_distance_since_last += movement.length()

	# Move existing coins
	var to_remove: Array[int] = []
	for i in _coins.size():
		if is_instance_valid(_coins[i]):
			_coins[i].position += movement
			if _is_off_screen(_coins[i]):
				to_remove.append(i)
		else:
			to_remove.append(i)

	for i in range(to_remove.size() - 1, -1, -1):
		if is_instance_valid(_coins[to_remove[i]]):
			_coins[to_remove[i]].queue_free()
		_coins.remove_at(to_remove[i])

	# Spawn new
	if _distance_since_last >= _next_spawn_distance:
		_spawn_coin()
		_distance_since_last = 0.0
		_next_spawn_distance = randf_range(
			_level_data.coin_frequency * 0.5,
			_level_data.coin_frequency * 1.5
		)

func _spawn_coin() -> void:
	if not coin_scene:
		return

	var coin: Area2D = coin_scene.instantiate()
	var spawn_offset: Vector2 = _level_data.get_spawn_offset(_viewport_size)

	if _level_data.is_horizontal():
		var y_pos: float = randf_range(_viewport_size.y - 250.0, _viewport_size.y - 120.0)
		coin.position = Vector2(spawn_offset.x, y_pos)
	else:
		var lane_x: float = [-150.0, 0.0, 150.0].pick_random()
		lane_x += _viewport_size.x / 2.0
		coin.position = Vector2(lane_x, spawn_offset.y)

	_coins.append(coin)
	add_child(coin)

func _is_off_screen(coin: Area2D) -> bool:
	var axis: String = _level_data.get_scroll_axis()
	var threshold: float = _level_data.get_destroy_threshold(_viewport_size)

	if axis == "x":
		if _level_data.scroll_direction.x > 0:
			return coin.position.x < threshold
		else:
			return coin.position.x > threshold
	else:
		if _level_data.scroll_direction.y > 0:
			return coin.position.y < threshold
		else:
			return coin.position.y > threshold
```

**Step 4: Commit**

```bash
git add scenes/coin.tscn scripts/coin.gd scripts/coin_spawner.gd
git commit -m "feat: add Coin scene and axis-aware CoinSpawner"
```

---

## Task 11: Teleporter Scene

**Goal:** Create the teleporter that appears at the end of a level and triggers the transition to the next level.

**Files:**
- Create: `scenes/teleporter.tscn`
- Create: `scripts/teleporter.gd`

**Step 1: Create Teleporter scene**

New scene → Root: `Area2D` → Name: "Teleporter"

```
Teleporter (Area2D)
├── ColorRect               (purple, 64x64 for horizontal, 960x64 for vertical)
├── CollisionShape2D         (RectangleShape2D matching visual)
├── Label                    (text: "TELEPORTER", centered)
```

ColorRect: size `Vector2(64, 64)`, color `Color(0.6, 0.0, 0.9, 0.8)` (purple, semi-transparent).
Label: text "TELEPORT", horizontal alignment center.

Save as `scenes/teleporter.tscn`.

**Step 2: Write teleporter.gd**

```gdscript
extends Area2D

signal activated

var _level_data: LevelData

func configure(data: LevelData) -> void:
	_level_data = data
	var viewport_size: Vector2 = get_viewport_rect().size

	if data.is_horizontal():
		# Full-height portal on the scroll axis
		$ColorRect.size = Vector2(64, 200)
		$ColorRect.position = Vector2(-32, -100)
		$CollisionShape2D.shape = RectangleShape2D.new()
		$CollisionShape2D.shape.size = Vector2(60, 196)
	else:
		# Full-width portal spanning all 3 lanes
		$ColorRect.size = Vector2(400, 64)
		$ColorRect.position = Vector2(-200, -32)
		$CollisionShape2D.shape = RectangleShape2D.new()
		$CollisionShape2D.shape.size = Vector2(396, 60)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		activated.emit()
```

**Step 3: Connect signal in scene**

Select Teleporter → Node → Signals → `body_entered` → Connect to self → `_on_body_entered`.

**Step 4: Commit**

```bash
git add scenes/teleporter.tscn scripts/teleporter.gd
git commit -m "feat: add Teleporter scene for level transitions"
```

---

## Task 12: TransitionManager Autoload

**Goal:** Create the TransitionManager that picks random levels and handles transitions.

**Files:**
- Create: `scripts/transition_manager.gd`
- Modify: `project.godot` (register autoload)

**Step 1: Create transition_manager.gd**

```gdscript
extends Node

signal level_ready(level_data: LevelData)
signal transition_started
signal transition_finished

var available_levels: Array[LevelData] = []
var current_level_data: LevelData
var _last_level_index: int = -1

func _ready() -> void:
	# Load all level resources
	available_levels = [
		preload("res://data/level_rio.tres"),
		preload("res://data/level_plataforma.tres"),
		preload("res://data/level_hellevator.tres"),
		preload("res://data/level_abduccion.tres"),
	]

## Pick a random level (not the same as the last one)
func pick_next_level() -> LevelData:
	var index: int = randi_range(0, available_levels.size() - 1)
	# Avoid repeating the same level
	while index == _last_level_index and available_levels.size() > 1:
		index = randi_range(0, available_levels.size() - 1)
	_last_level_index = index
	current_level_data = available_levels[index]
	return current_level_data

## Start transition to a new level
func transition_to_next() -> void:
	transition_started.emit()
	var next_data: LevelData = pick_next_level()
	# Small delay for transition feel
	await get_tree().create_timer(0.5).timeout
	level_ready.emit(next_data)
	transition_finished.emit()

## Start the first level (no transition animation)
func start_first_level() -> void:
	var data: LevelData = pick_next_level()
	level_ready.emit(data)
```

**Step 2: Register as Autoload**

Project → Project Settings → Autoload → Add:
- Path: `res://scripts/transition_manager.gd`
- Name: `TransitionManager`
- Enabled: ✓

**Step 3: Commit**

```bash
git add scripts/transition_manager.gd project.godot
git commit -m "feat: add TransitionManager autoload for random level selection"
```

---

## Task 13: Level Scene Assembly

**Goal:** Create the Level scene that wires everything together — player, world scroller, spawners, terrain, and teleporter.

**Files:**
- Create: `scenes/level.tscn`
- Create: `scripts/level.gd`

**Step 1: Build Level scene tree**

Create new scene → Root: `Node2D` → Name: "Level"

```
Level (Node2D)
├── Background (ColorRect)          (full viewport, bg_color from LevelData)
├── Ground (StaticBody2D)           (floor collision for horizontal levels)
│   └── CollisionShape2D            (WorldBoundaryShape2D)
├── World (Node2D)                  (attach world_scroller.gd)
│   ├── TerrainManager (Node2D)     (attach terrain_manager.gd)
│   ├── ObstacleSpawner (Node2D)    (attach obstacle_spawner.gd)
│   └── CoinSpawner (Node2D)        (attach coin_spawner.gd)
├── Player (instance player.tscn)
└── UI (CanvasLayer)
    ├── XPLabel (Label)              (top-left, font_size 32)
    ├── DistanceBar (ProgressBar)    (top, full width)
    └── LevelNameLabel (Label)       (top-center, font_size 48)
```

For Ground/CollisionShape2D:
- Shape: WorldBoundaryShape2D
- Ground position: `Vector2(0, viewport.y - 100)` → set in code

For ObstacleSpawner: set export `obstacle_scene` → `scenes/obstacle.tscn`
For CoinSpawner: set export `coin_scene` → `scenes/coin.tscn`

Attach scripts to: World (world_scroller.gd), TerrainManager (terrain_manager.gd), ObstacleSpawner (obstacle_spawner.gd), CoinSpawner (coin_spawner.gd).

Save as `scenes/level.tscn`.

**Step 2: Write level.gd**

Attach to Level root:

```gdscript
extends Node2D

@onready var background: ColorRect = $Background
@onready var ground: StaticBody2D = $Ground
@onready var world: Node2D = $World
@onready var terrain_manager: Node2D = $World/TerrainManager
@onready var obstacle_spawner: Node2D = $World/ObstacleSpawner
@onready var coin_spawner: Node2D = $World/CoinSpawner
@onready var player: CharacterBody2D = $Player
@onready var xp_label: Label = $UI/XPLabel
@onready var distance_bar: ProgressBar = $UI/DistanceBar
@onready var level_name_label: Label = $UI/LevelNameLabel

var level_data: LevelData
var level_distance: float = 0.0
var _teleporter_spawned: bool = false

func configure(data: LevelData) -> void:
	level_data = data
	level_distance = GameManager.calculate_level_distance(
		data.base_distance, data.distance_scale_per_xp
	)

func _ready() -> void:
	if not level_data:
		return

	var viewport_size: Vector2 = get_viewport_rect().size

	# Setup background
	background.size = viewport_size
	background.color = level_data.bg_color

	# Setup ground (only for horizontal levels)
	if level_data.gravity_enabled:
		ground.position = Vector2(0, viewport_size.y - 100)
		ground.visible = true
	else:
		ground.position = Vector2(0, -9999)  # move off-screen
		ground.visible = false

	# Setup player
	player.add_to_group("player")
	if level_data.is_horizontal():
		player.position = Vector2(200, viewport_size.y - 150)
	else:
		player.position = Vector2(viewport_size.x / 2.0, viewport_size.y / 2.0)
	player.configure(level_data)

	# Setup world systems
	world.configure(level_data)
	terrain_manager.configure(level_data)
	obstacle_spawner.configure(level_data)
	coin_spawner.configure(level_data)

	# Setup UI
	distance_bar.max_value = level_distance
	distance_bar.value = 0
	level_name_label.text = level_data.level_name
	xp_label.text = "XP: %d" % GameManager.total_xp

	# Connect signals
	world.distance_updated.connect(_on_distance_updated)
	GameManager.xp_changed.connect(_on_xp_changed)
	GameManager.game_over.connect(_on_game_over)

	# Start
	world.start()
	obstacle_spawner.start()
	coin_spawner.start()

	# Fade out level name after 2 seconds
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(level_name_label, "modulate:a", 0.0, 0.5)

func _on_distance_updated(total: float) -> void:
	distance_bar.value = min(total, level_distance)

	if total >= level_distance and not _teleporter_spawned:
		_spawn_teleporter()

func _on_xp_changed(new_xp: int) -> void:
	xp_label.text = "XP: %d" % new_xp

func _on_game_over() -> void:
	world.stop()
	obstacle_spawner.stop()
	coin_spawner.stop()

func _spawn_teleporter() -> void:
	_teleporter_spawned = true
	obstacle_spawner.stop()

	var teleporter_scene: PackedScene = preload("res://scenes/teleporter.tscn")
	var teleporter: Area2D = teleporter_scene.instantiate()
	teleporter.configure(level_data)

	var spawn_pos: Vector2 = level_data.get_spawn_offset(get_viewport_rect().size)
	if level_data.is_horizontal():
		teleporter.position = Vector2(spawn_pos.x, get_viewport_rect().size.y - 200)
	else:
		teleporter.position = Vector2(get_viewport_rect().size.x / 2.0, spawn_pos.y)

	teleporter.activated.connect(_on_teleporter_activated)
	$World.add_child(teleporter)

func _on_teleporter_activated() -> void:
	GameManager.complete_level(level_data.level_complete_bonus)
	TransitionManager.transition_to_next()
```

**Step 3: Commit**

```bash
git add scenes/level.tscn scripts/level.gd
git commit -m "feat: add Level scene that wires all systems with LevelData configuration"
```

---

## Task 14: Main Scene (Persistent Root)

**Goal:** Create the Main scene that persists across levels and manages Level instantiation.

**Files:**
- Create: `scenes/main.tscn`
- Create: `scripts/main.gd`
- Modify: `project.godot` (set as main scene)

**Step 1: Build Main scene**

New scene → Root: `Node2D` → Name: "Main"

```
Main (Node2D)
├── LevelContainer (Node2D)     (levels get added here as children)
├── UIOverlay (CanvasLayer)     (for game over screen, menus)
```

Save as `scenes/main.tscn`.

**Step 2: Write main.gd**

```gdscript
extends Node2D

const LEVEL_SCENE: PackedScene = preload("res://scenes/level.tscn")
const GAME_OVER_SCENE: PackedScene = preload("res://scenes/game_over.tscn")

@onready var level_container: Node2D = $LevelContainer
@onready var ui_overlay: CanvasLayer = $UIOverlay

var _current_level: Node2D

func _ready() -> void:
	TransitionManager.level_ready.connect(_on_level_ready)
	GameManager.game_over.connect(_on_game_over)

func start_game() -> void:
	# Clear any existing UI overlays
	for child in ui_overlay.get_children():
		child.queue_free()

	GameManager.start_game()
	TransitionManager.start_first_level()

func _on_level_ready(data: LevelData) -> void:
	# Remove old level
	if _current_level:
		_current_level.queue_free()
		await get_tree().process_frame

	# Instantiate new level
	_current_level = LEVEL_SCENE.instantiate()
	_current_level.configure(data)
	level_container.add_child(_current_level)

func _on_game_over() -> void:
	# Show game over screen after a brief delay
	await get_tree().create_timer(1.0).timeout
	var game_over_screen := GAME_OVER_SCENE.instantiate()
	game_over_screen.retry_requested.connect(_on_retry)
	game_over_screen.menu_requested.connect(_on_menu)
	ui_overlay.add_child(game_over_screen)

func _on_retry() -> void:
	start_game()

func _on_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
```

**Step 3: Set as main scene**

Project → Project Settings → Application → Run → Main Scene → `res://scenes/main_menu.tscn` (we'll create menu next, for now point to `main.tscn` temporarily).

**Step 4: Commit**

```bash
git add scenes/main.tscn scripts/main.gd project.godot
git commit -m "feat: add persistent Main scene with level lifecycle management"
```

---

## Task 15: Main Menu Screen

**Goal:** Create the main menu with Play button, XP display, and high score.

**Files:**
- Create: `scenes/main_menu.tscn`
- Create: `scripts/main_menu.gd`

**Step 1: Build Main Menu scene**

New scene → Root: `Control` → Name: "MainMenu" → Set Layout to "Full Rect"

```
MainMenu (Control, full rect)
├── Background (ColorRect, full rect, dark color)
├── VBoxContainer (centered)
│   ├── TitleLabel (Label, "DASH RUNNER", font_size 72, center)
│   ├── Spacer (Control, min_size_y = 40)
│   ├── PlayButton (Button, "PLAY", font_size 36)
│   ├── Spacer2 (Control, min_size_y = 20)
│   ├── XPLabel (Label, "XP: 0", font_size 24, center)
│   └── HighScoreLabel (Label, "High Score: 0", font_size 24, center)
```

Center the VBoxContainer using anchors (center preset).

Save as `scenes/main_menu.tscn`.

**Step 2: Write main_menu.gd**

```gdscript
extends Control

func _ready() -> void:
	$VBoxContainer/XPLabel.text = "XP: %d" % GameManager.total_xp
	$VBoxContainer/HighScoreLabel.text = "High Score: %d" % GameManager.high_score
	$VBoxContainer/PlayButton.pressed.connect(_on_play)

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
```

**Step 3: Wire main.gd to auto-start**

In `scripts/main.gd`, update `_ready()`:

```gdscript
func _ready() -> void:
	TransitionManager.level_ready.connect(_on_level_ready)
	GameManager.game_over.connect(_on_game_over)
	# Auto-start when Main scene loads (coming from menu)
	start_game()
```

**Step 4: Set main scene to main_menu**

Project → Project Settings → Application → Run → Main Scene → `res://scenes/main_menu.tscn`

**Step 5: Commit**

```bash
git add scenes/main_menu.tscn scripts/main_menu.gd scripts/main.gd project.godot
git commit -m "feat: add Main Menu screen with XP display and play button"
```

---

## Task 16: Game Over Screen

**Goal:** Create the game over overlay with score, XP penalty, retry, and menu buttons.

**Files:**
- Create: `scenes/game_over.tscn`
- Create: `scripts/game_over.gd`

**Step 1: Build Game Over scene**

New scene → Root: `Control` → Name: "GameOverScreen" → Full Rect

```
GameOverScreen (Control, full rect)
├── DimBackground (ColorRect, full rect, Color(0, 0, 0, 0.7))
├── Panel (PanelContainer, centered)
│   └── VBoxContainer
│       ├── GameOverLabel (Label, "GAME OVER", font_size 60, center)
│       ├── SessionXPLabel (Label, "Session XP: 0", font_size 28, center)
│       ├── TotalXPLabel (Label, "Total XP: 0", font_size 28, center)
│       ├── HighScoreLabel (Label, "", font_size 28, center)
│       ├── Spacer (Control, min_size_y = 20)
│       ├── RetryButton (Button, "RETRY", font_size 28)
│       └── MenuButton (Button, "MENU", font_size 28)
```

Save as `scenes/game_over.tscn`.

**Step 2: Write game_over.gd**

```gdscript
extends Control

signal retry_requested
signal menu_requested

func _ready() -> void:
	$Panel/VBoxContainer/SessionXPLabel.text = "Session XP: %d" % GameManager.session_xp
	$Panel/VBoxContainer/TotalXPLabel.text = "Total XP: %d" % GameManager.total_xp

	if GameManager.session_xp >= GameManager.high_score:
		$Panel/VBoxContainer/HighScoreLabel.text = "NEW HIGH SCORE!"
	else:
		$Panel/VBoxContainer/HighScoreLabel.text = "High Score: %d" % GameManager.high_score

	$Panel/VBoxContainer/RetryButton.pressed.connect(_on_retry)
	$Panel/VBoxContainer/MenuButton.pressed.connect(_on_menu)

func _on_retry() -> void:
	retry_requested.emit()
	queue_free()

func _on_menu() -> void:
	menu_requested.emit()
	queue_free()
```

**Step 3: Commit**

```bash
git add scenes/game_over.tscn scripts/game_over.gd
git commit -m "feat: add Game Over screen with XP display and retry/menu buttons"
```

---

## Task 17: Full Integration — First Playable

**Goal:** Wire everything together and verify the full game loop works: menu → play → level → die → game over → retry.

**Files:**
- Modify: Various files for bug fixes and wiring

**Step 1: Verify autoload order**

In Project → Project Settings → Autoload, ensure this order:
1. `GameManager`
2. `SwipeDetector`
3. `TransitionManager`

**Step 2: Run the full game loop**

Press F5. Expected flow:
1. Main Menu appears with "DASH RUNNER", Play button, XP: 0, High Score: 0
2. Click Play → transitions to Main scene
3. A random level loads (check level name appears briefly)
4. World scrolls in the correct direction
5. Obstacles spawn from the leading edge
6. Coins spawn and can be collected (XP counter increases)
7. Distance bar fills up as you progress
8. Player can jump/crouch (horizontal) or dodge left/right (vertical)
9. Hitting an obstacle → game stops → Game Over screen appears
10. Retry → new random level starts
11. Menu → back to main menu with updated XP

**Step 3: Debug and fix issues**

Common issues to check:
- Player falls through floor in horizontal levels → verify Ground StaticBody2D position
- Obstacles don't spawn → verify obstacle_scene export is set in Inspector
- Coins don't spawn → verify coin_scene export is set in Inspector
- Swipe input doesn't work → verify autoloads are registered
- Level name wrong → verify .tres files have level_name set
- Teleporter doesn't appear → check distance_updated signal is connected

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: complete first playable with full game loop integration"
```

---

## Task 18: Android Export Setup

**Goal:** Configure Godot to build an APK for Android.

**Step 1: Install Android build tools**

In Godot: Editor → Editor Settings → Export → Android:
- Set Java SDK path (JDK 17)
- Set Android SDK path
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

Create `build/` directory first. Add `build/` to `.gitignore` if not already there.

**Step 4: Test on device**

```bash
adb install build/dash-runner-debug.apk
```

Verify:
- Game opens in landscape
- Swipe controls work on touchscreen
- All 4 level directions work
- XP persists after closing and reopening

**Step 5: Commit**

```bash
git add .gitignore
git commit -m "feat: add Android export configuration"
```

---

## Summary

| Task | Description | Key Files |
|------|-------------|-----------|
| 1 | Clean up old project | Delete old scenes/scripts |
| 2 | LevelData Resource | `scripts/level_data.gd` |
| 3 | 4 Level Data files | `data/*.tres` |
| 4 | GameManager Autoload | `scripts/game_manager.gd` |
| 5 | SwipeDetector Autoload | `scripts/swipe_detector.gd` |
| 6 | Player Scene | `scenes/player.tscn`, `scripts/player.gd` |
| 7 | WorldScroller | `scripts/world_scroller.gd` |
| 8 | TerrainManager | `scripts/terrain_manager.gd` |
| 9 | Obstacle + Spawner | `scenes/obstacle.tscn`, `scripts/obstacle_spawner.gd` |
| 10 | Coin + Spawner | `scenes/coin.tscn`, `scripts/coin_spawner.gd` |
| 11 | Teleporter | `scenes/teleporter.tscn`, `scripts/teleporter.gd` |
| 12 | TransitionManager | `scripts/transition_manager.gd` |
| 13 | Level Scene | `scenes/level.tscn`, `scripts/level.gd` |
| 14 | Main Scene | `scenes/main.tscn`, `scripts/main.gd` |
| 15 | Main Menu | `scenes/main_menu.tscn`, `scripts/main_menu.gd` |
| 16 | Game Over Screen | `scenes/game_over.tscn`, `scripts/game_over.gd` |
| 17 | Full Integration | Wire everything, verify game loop |
| 18 | Android Export | Build pipeline, APK |

**Estimated: 18 tasks | Each: 10-20 min | Total: ~4-6 hours**
