extends Node
class_name CombatController

## Handles player combat: melee and ranged attacks

signal melee_attacked(cooldown: float)
signal ranged_attacked(cooldown: float)

const MELEE_COOLDOWN: float = 0.4
const RANGED_COOLDOWN: float = 0.8
const DOUBLE_TAP_WINDOW: float = 0.3
const MELEE_RANGE: float = 150.0

var melee_attack_scene: PackedScene = preload("res://scenes/melee_attack.tscn")
var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")

var _melee_cooldown_timer: float = 0.0
var _ranged_cooldown_timer: float = 0.0
var _last_tap_time: float = 0.0
var _tap_count: int = 0

var _player: CharacterBody2D
var _level_data: LevelData
var _enabled: bool = true

# Dirección hacia donde vienen los enemigos (calculada una vez al configurar)
var _attack_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	_player = get_parent() as CharacterBody2D

func configure(data: LevelData) -> void:
	_level_data = data
	# Los enemigos vienen en la misma dirección que scrollea el nivel
	# Río (scroll derecha): enemigos desde la derecha → atacar derecha = scroll_direction
	# Plataforma (scroll izquierda): enemigos desde la izquierda → atacar izquierda = scroll_direction
	_attack_direction = data.scroll_direction.normalized()

func enable() -> void:
	_enabled = true

func disable() -> void:
	_enabled = false

func get_melee_cooldown_ratio() -> float:
	var max_cd: float = MELEE_COOLDOWN * (0.5 if PowerUpManager.is_active("attack_speed") else 1.0)
	return clamp(_melee_cooldown_timer / max_cd, 0.0, 1.0)

func get_ranged_cooldown_ratio() -> float:
	var max_cd: float = RANGED_COOLDOWN * (0.5 if PowerUpManager.is_active("attack_speed") else 1.0)
	return clamp(_ranged_cooldown_timer / max_cd, 0.0, 1.0)

func _process(delta: float) -> void:
	if _melee_cooldown_timer > 0:
		_melee_cooldown_timer -= delta
	if _ranged_cooldown_timer > 0:
		_ranged_cooldown_timer -= delta
	if Time.get_ticks_msec() / 1000.0 - _last_tap_time > DOUBLE_TAP_WINDOW:
		_tap_count = 0

func _unhandled_input(event: InputEvent) -> void:
	if not _enabled:
		return

	# Teclado: Z = melee, X = ranged
	if event.is_action_pressed("melee_attack"):
		_try_melee_attack()
		return
	if event.is_action_pressed("ranged_attack"):
		_try_ranged_attack()
		return

	# Touch / click → tap simple = melee, doble tap = ranged
	if event is InputEventScreenTouch and event.pressed:
		_handle_tap()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_tap()

func _handle_tap() -> void:
	var current_time := Time.get_ticks_msec() / 1000.0
	if current_time - _last_tap_time <= DOUBLE_TAP_WINDOW:
		_tap_count += 1
	else:
		_tap_count = 1
	_last_tap_time = current_time

	if _tap_count >= 2:
		_try_ranged_attack()
		_tap_count = 0
	else:
		_try_melee_attack()

func _try_melee_attack() -> void:
	if _melee_cooldown_timer > 0:
		return
	var cooldown: float = MELEE_COOLDOWN * (0.5 if PowerUpManager.is_active("attack_speed") else 1.0)
	_melee_cooldown_timer = cooldown
	_spawn_melee_attack()
	melee_attacked.emit(cooldown)

func _try_ranged_attack() -> void:
	if _ranged_cooldown_timer > 0:
		return
	var cooldown: float = RANGED_COOLDOWN * (0.5 if PowerUpManager.is_active("attack_speed") else 1.0)
	_ranged_cooldown_timer = cooldown
	_spawn_projectile()
	ranged_attacked.emit(cooldown)

func _spawn_melee_attack() -> void:
	var attack: MeleeAttack = melee_attack_scene.instantiate()

	# Escalar con big_sword
	var range_mult: float = 1.8 if PowerUpManager.is_active("big_sword") else 1.0
	var offset: Vector2 = _attack_direction * MELEE_RANGE * 0.4 * range_mult

	# Rotar el hitbox para que apunte en la dirección correcta
	attack.rotation = _attack_direction.angle()
	if PowerUpManager.is_active("big_sword"):
		attack.scale = Vector2(range_mult, range_mult)

	attack.position = _player.position + offset
	_player.get_parent().add_child(attack)

func _spawn_projectile() -> void:
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.position = _player.position
	projectile.direction = _attack_direction
	_player.get_parent().add_child(projectile)
