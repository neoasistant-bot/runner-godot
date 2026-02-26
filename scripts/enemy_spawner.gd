extends Node2D
class_name EnemySpawner

@export var slime_scene: PackedScene
@export var bat_scene: PackedScene
@export var skeleton_scene: PackedScene
@export var ghost_scene: PackedScene

var _level_data: LevelData
var _viewport_size: Vector2
var _spawn_timer: float = 0.0
var _initial_delay: float = 3.0  # No spawns for first 3 seconds
var _running: bool = false

# Spawn frequency decreases (faster) with difficulty
var _base_spawn_interval: float = 4.0
var _min_spawn_interval: float = 1.5

func configure(data: LevelData) -> void:
	_level_data = data
	_viewport_size = get_viewport_rect().size
	_spawn_timer = -_initial_delay  # Start negative for delay

func start() -> void:
	_running = true
	GameManager.phase_changed.connect(_on_phase_changed)

func _on_phase_changed(_phase: int) -> void:
	pass  # spawn logic already checks phase per-spawn

func stop() -> void:
	_running = false

func _process(delta: float) -> void:
	if not _running or not _level_data:
		return
	
	_spawn_timer += delta
	
	var interval := _get_spawn_interval()
	if _spawn_timer >= interval:
		_spawn_timer = 0.0
		_spawn_enemy()

func _get_spawn_interval() -> float:
	var difficulty := GameManager.get_difficulty_level()
	var interval := _base_spawn_interval - (difficulty * 0.2)
	return max(interval, _min_spawn_interval)

func _spawn_enemy() -> void:
	# No spawnar enemigos hasta Fase ENEMIES
	if GameManager.get_phase() < GameManager.DifficultyPhase.ENEMIES:
		return

	var enemy_scene := _pick_enemy_type()
	if not enemy_scene:
		return
	
	var enemy: Enemy = enemy_scene.instantiate()
	enemy.configure(_level_data)
	enemy.position = _get_spawn_position()
	enemy.died.connect(_on_enemy_died)
	add_child(enemy)

func _pick_enemy_type() -> PackedScene:
	var phase: int = GameManager.get_phase()
	var roll: float = randf()

	match phase:
		GameManager.DifficultyPhase.ENEMIES:
			return slime_scene
		GameManager.DifficultyPhase.MIX_1:
			return slime_scene if roll < 0.6 else bat_scene
		GameManager.DifficultyPhase.MIX_2:
			if roll < 0.4:
				return slime_scene
			elif roll < 0.7:
				return bat_scene
			else:
				return skeleton_scene
		GameManager.DifficultyPhase.FULL:
			if roll < 0.3:
				return slime_scene
			elif roll < 0.5:
				return bat_scene
			elif roll < 0.75:
				return skeleton_scene
			else:
				return ghost_scene
		_:
			return slime_scene

func _get_spawn_position() -> Vector2:
	var pos := Vector2.ZERO
	var margin := 100.0
	
	# Spawn opposite to scroll direction (where enemies come from)
	match _level_data.scroll_direction:
		Vector2(-1, 0):  # Scrolling left, enemies from right
			pos.x = _viewport_size.x + margin
			pos.y = randf_range(200, _viewport_size.y - 200)
		Vector2(1, 0):   # Scrolling right, enemies from left
			pos.x = -margin
			pos.y = randf_range(200, _viewport_size.y - 200)
		Vector2(0, -1):  # Scrolling up, enemies from bottom
			pos.x = randf_range(200, _viewport_size.x - 200)
			pos.y = _viewport_size.y + margin
		Vector2(0, 1):   # Scrolling down, enemies from top
			pos.x = randf_range(200, _viewport_size.x - 200)
			pos.y = -margin
	
	return pos

func _on_enemy_died(xp_value: int) -> void:
	GameManager.add_xp(xp_value)
