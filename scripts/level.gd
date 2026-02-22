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
		ground.position = Vector2(0, -9999)
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
