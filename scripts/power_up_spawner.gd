extends Node2D
class_name PowerUpSpawner

@export var power_up_scene: PackedScene

var _level_data: LevelData
var _viewport_size: Vector2
var _spawn_timer: float = 0.0
var _next_interval: float = 0.0
var _running: bool = false
var _active_powerup: Node = null

const INTERVAL_MIN: float = 20.0
const INTERVAL_MAX: float = 35.0
const TYPES: Array[String] = ["attack_speed", "big_sword", "laser"]
const TYPE_LABELS: Dictionary = {
	"attack_speed": "⚡",
	"big_sword": "⚔️",
	"laser": "🔵",
}

func configure(data: LevelData) -> void:
	_level_data = data
	_viewport_size = get_viewport_rect().size
	_next_interval = randf_range(INTERVAL_MIN, INTERVAL_MAX)

func start() -> void:
	_running = true

func stop() -> void:
	_running = false

func _process(delta: float) -> void:
	if not _running or not _level_data:
		return
	# Solo activo en Fase 2+ (HAZARDS)
	if GameManager.get_phase() < GameManager.DifficultyPhase.HAZARDS:
		return
	# Solo 1 power-up en pantalla a la vez
	if is_instance_valid(_active_powerup):
		return

	_spawn_timer += delta
	if _spawn_timer >= _next_interval:
		_spawn_timer = 0.0
		_next_interval = randf_range(INTERVAL_MIN, INTERVAL_MAX)
		_spawn_power_up()

func _spawn_power_up() -> void:
	if not power_up_scene:
		return

	var pu: PowerUp = power_up_scene.instantiate()
	var type: String = TYPES[randi() % TYPES.size()]
	pu.power_up_type = type

	# Etiqueta visual según tipo
	var label: Label = pu.get_node_or_null("Label")
	if label:
		label.text = TYPE_LABELS.get(type, "★")

	# Posición random con margen
	var margin: float = 150.0
	pu.position = Vector2(
		randf_range(margin, _viewport_size.x - margin),
		randf_range(margin, _viewport_size.y - margin)
	)

	add_child(pu)
	_active_powerup = pu
