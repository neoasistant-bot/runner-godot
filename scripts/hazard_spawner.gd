extends Node2D
class_name HazardSpawner

@export var lightning_scene: PackedScene
@export var shockwave_scene: PackedScene

var _level_data: LevelData
var _viewport_size: Vector2
var _spawn_timer: float = 0.0
var _initial_delay: float = 5.0    # Esperar un poco antes del primer hazard
var _running: bool = false

const BASE_INTERVAL_MIN: float = 8.0
const BASE_INTERVAL_MAX: float = 12.0

var _next_interval: float = 0.0

func configure(data: LevelData) -> void:
	_level_data = data
	_viewport_size = get_viewport_rect().size
	_spawn_timer = -_initial_delay
	_next_interval = _pick_interval()

func start() -> void:
	_running = true

func stop() -> void:
	_running = false

func _process(delta: float) -> void:
	if not _running or not _level_data:
		return

	_spawn_timer += delta

	if _spawn_timer >= _next_interval:
		_spawn_timer = 0.0
		_next_interval = _pick_interval()
		_spawn_hazard()

func _pick_interval() -> float:
	# Con más dificultad, hazards un poco más frecuentes (mínimo 6s)
	var difficulty := GameManager.get_difficulty_level()
	var reduction := minf(difficulty * 0.1, 2.0)
	return randf_range(
		max(BASE_INTERVAL_MIN - reduction, 6.0),
		max(BASE_INTERVAL_MAX - reduction, 8.0)
	)

func _spawn_hazard() -> void:
	# Solo hazards relevantes según el tipo de nivel
	var hazard_type := _pick_hazard_type()

	match hazard_type:
		"lightning":
			_spawn_lightning()
		"shockwave":
			_spawn_shockwave()

func _pick_hazard_type() -> String:
	if not lightning_scene:
		return "shockwave"
	if not shockwave_scene:
		return "lightning"
	# 50/50 por ahora; se puede ponderar por nivel después
	return "lightning" if randf() < 0.5 else "shockwave"

func _spawn_lightning() -> void:
	if not lightning_scene:
		return

	var hazard: HazardLightning = lightning_scene.instantiate()

	# Posición X aleatoria dentro del viewport, con margen
	var margin := 150.0
	var x := randf_range(margin, _viewport_size.x - margin)

	# Y: arriba de la pantalla, cayendo en pantalla completa (ocupa toda la altura)
	hazard.position = Vector2(x, 0)

	add_child(hazard)

func _spawn_shockwave() -> void:
	if not shockwave_scene:
		return

	var hazard: HazardShockwave = shockwave_scene.instantiate()

	# La onda viaja en la dirección del scroll
	var dir: float
	var start_x: float

	if _level_data.is_horizontal():
		# Viene del lado de spawn de enemigos (off-screen)
		if _level_data.scroll_direction.x < 0:
			dir = -1.0
			start_x = _viewport_size.x + 50
		else:
			dir = 1.0
			start_x = -50.0
	else:
		# En niveles verticales la onda viaja horizontalmente igual
		dir = 1.0 if randf() < 0.5 else -1.0
		start_x = -50.0 if dir > 0 else _viewport_size.x + 50

	# Y baja: justo sobre el suelo
	var ground_y := _viewport_size.y - 140.0

	hazard.configure(dir, _viewport_size.x)
	hazard.position = Vector2(start_x, ground_y)
	add_child(hazard)
