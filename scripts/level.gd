extends Node2D

@onready var background: ColorRect = $Background
@onready var ground: StaticBody2D = $Ground
@onready var world: Node2D = $World
@onready var terrain_manager: Node2D = $World/TerrainManager
@onready var obstacle_spawner: Node2D = $World/ObstacleSpawner
@onready var coin_spawner: Node2D = $World/CoinSpawner
@onready var enemy_spawner: Node2D = $World/EnemySpawner
@onready var power_up_spawner: Node2D = $World/PowerUpSpawner
@onready var player: CharacterBody2D = $Player
@onready var xp_label: Label = $UI/XPLabel
@onready var distance_bar: ProgressBar = $UI/DistanceBar
@onready var level_name_label: Label = $UI/LevelNameLabel
@onready var score_label: Label = $UI/TopBar/ScoreContainer/ScoreLabel
@onready var distance_label: Label = $UI/TopBar/DistanceContainer/DistanceLabel
@onready var high_score_indicator: Label = $UI/HighScoreIndicator
@onready var power_up_panel: VBoxContainer = $UI/PowerUpPanel
@onready var power_up_icon: Label = $UI/PowerUpPanel/PowerUpIcon
@onready var power_up_bar: ProgressBar = $UI/PowerUpPanel/PowerUpBar
@onready var melee_bar: ProgressBar = $UI/CombatHUD/MeleeSlot/MeleeBar
@onready var ranged_bar: ProgressBar = $UI/CombatHUD/RangedSlot/RangedBar
@onready var melee_icon: Label = $UI/CombatHUD/MeleeSlot/MeleeIcon
@onready var ranged_icon: Label = $UI/CombatHUD/RangedSlot/RangedIcon

var _combat_controller: CombatController = null

var _total_distance: float = 0.0

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
		ground.get_node("CollisionShape2D").disabled = false
	else:
		# Disable ground collision entirely for vertical levels
		ground.visible = false
		ground.get_node("CollisionShape2D").disabled = true

	# Setup player — position depends on scroll direction
	player.add_to_group("player")
	if level_data.is_horizontal():
		if level_data.scroll_direction.x > 0:
			# Río: world scrolls left, player on left side
			player.position = Vector2(200, viewport_size.y - 150)
		else:
			# Plataforma: world scrolls right, player on right side
			player.position = Vector2(viewport_size.x - 200, viewport_size.y - 150)
	else:
		if level_data.scroll_direction.y > 0:
			# Hellevator: world scrolls up, player near top
			player.position = Vector2(viewport_size.x / 2.0, 250)
		else:
			# Abducción: world scrolls down, player near bottom
			player.position = Vector2(viewport_size.x / 2.0, viewport_size.y - 250)
	player.configure(level_data)

	# Setup world systems
	world.configure(level_data)
	terrain_manager.configure(level_data)
	obstacle_spawner.configure(level_data)
	coin_spawner.configure(level_data)
	enemy_spawner.configure(level_data)
	power_up_spawner.configure(level_data)

	# Setup UI
	distance_bar.max_value = level_distance
	distance_bar.value = 0
	level_name_label.text = level_data.level_name
	xp_label.text = "XP: %d" % GameManager.total_xp
	score_label.text = "%d" % GameManager.session_xp
	distance_label.text = "0m"
	high_score_indicator.text = "★ HIGH SCORE: %d" % GameManager.high_score
	if GameManager.high_score == 0:
		high_score_indicator.visible = false

	# Obtener CombatController del player
	_combat_controller = player.get_node_or_null("CombatController")

	# Connect signals
	world.distance_updated.connect(_on_distance_updated)
	GameManager.xp_changed.connect(_on_xp_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.phase_changed.connect(_on_phase_changed)
	PowerUpManager.activated.connect(_on_power_up_activated)
	PowerUpManager.expired.connect(_on_power_up_expired)

	# Start
	world.start()
	obstacle_spawner.start()
	coin_spawner.start()
	enemy_spawner.start()
	power_up_spawner.start()

	# Fade out level name after 2 seconds
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(level_name_label, "modulate:a", 0.0, 0.5)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# ESC pressed — stop the game and go back to menu
		world.stop()
		obstacle_spawner.stop()
		coin_spawner.stop()
		enemy_spawner.stop()
		power_up_spawner.stop()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_distance_updated(total: float) -> void:
	distance_bar.value = min(total, level_distance)
	_total_distance = total
	distance_label.text = "%dm" % int(total)

	if total >= level_distance and not _teleporter_spawned:
		_spawn_teleporter()

func _on_xp_changed(new_xp: int) -> void:
	xp_label.text = "XP: %d" % new_xp
	score_label.text = "%d" % GameManager.session_xp
	
	# Check for new high score during gameplay
	if GameManager.session_xp > GameManager.high_score and GameManager.high_score > 0:
		_on_new_high_score()

func _on_new_high_score() -> void:
	# Flash the high score indicator
	high_score_indicator.text = "★ NEW HIGH SCORE!"
	high_score_indicator.visible = true
	high_score_indicator.add_theme_color_override("font_color", Color.GOLD)
	
	var tween := create_tween()
	tween.tween_property(high_score_indicator, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(high_score_indicator, "scale", Vector2(1.0, 1.0), 0.1)

func _process(_delta: float) -> void:
	# Power-up timer
	if not PowerUpManager.get_active_type().is_empty():
		power_up_bar.value = PowerUpManager.get_remaining_ratio()
		var ratio: float = PowerUpManager.get_remaining_ratio()
		if ratio < 0.2:
			power_up_panel.modulate.a = 0.4 + 0.6 * abs(sin(Time.get_ticks_msec() * 0.01))
		else:
			power_up_panel.modulate.a = 1.0

	# Combat HUD — cooldown bars (0 = listo, 1 = en cooldown)
	if _combat_controller:
		var m_ratio: float = _combat_controller.get_melee_cooldown_ratio()
		var r_ratio: float = _combat_controller.get_ranged_cooldown_ratio()
		melee_bar.value = m_ratio
		ranged_bar.value = r_ratio
		# Oscurecer ícono cuando está en cooldown
		melee_icon.modulate.a = 0.4 if m_ratio > 0.0 else 1.0
		ranged_icon.modulate.a = 0.4 if r_ratio > 0.0 else 1.0

func _on_power_up_activated(type: String) -> void:
	const ICONS: Dictionary = {
		"attack_speed": "⚡ VEL. ATAQUE",
		"big_sword": "⚔️ ESPADA+",
		"laser": "🔵 LASER",
	}
	power_up_icon.text = ICONS.get(type, "★")
	power_up_bar.value = 1.0
	power_up_panel.visible = true
	power_up_panel.modulate.a = 1.0

func _on_power_up_expired(_type: String) -> void:
	power_up_panel.visible = false

func _on_phase_changed(phase: int) -> void:
	var messages: Array[String] = [
		"",
		"⚡ ¡Cuidado con los ataques!",
		"👾 ¡Aparecen enemigos!",
		"💀 ¡Más peligros!",
		"🔥 ¡Esto se complica!",
		"☠️ ¡Modo infernal!"
	]
	if phase > 0 and phase < messages.size():
		level_name_label.text = messages[phase]
		level_name_label.modulate.a = 1.0
		var tween := create_tween()
		tween.tween_interval(2.5)
		tween.tween_property(level_name_label, "modulate:a", 0.0, 0.5)

func _on_game_over() -> void:
	world.stop()
	obstacle_spawner.stop()
	coin_spawner.stop()
	enemy_spawner.stop()
	power_up_spawner.stop()

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
