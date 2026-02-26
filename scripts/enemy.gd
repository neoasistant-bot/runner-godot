extends Area2D
class_name Enemy

signal died(xp_value: int)

@export var max_hp: int = 1
@export var speed: float = 150.0
@export var xp_value: int = 15
@export var immune_to_melee: bool = false

var hp: int
var _level_data: LevelData
var _move_direction: Vector2

const DamageNumber = preload("res://scenes/damage_number.tscn")

func _ready() -> void:
	add_to_group("enemies")
	hp = max_hp

func configure(data: LevelData) -> void:
	_level_data = data
	# Enemies move opposite to scroll direction (towards player)
	_move_direction = -data.scroll_direction.normalized()

func _physics_process(delta: float) -> void:
	position += _move_direction * speed * delta
	_check_bounds()

func _check_bounds() -> void:
	var viewport_size := get_viewport_rect().size
	# Remove if too far off screen
	if position.x < -100 or position.x > viewport_size.x + 100:
		queue_free()
	if position.y < -100 or position.y > viewport_size.y + 100:
		queue_free()

func take_damage(damage: int, is_melee: bool = false) -> void:
	if is_melee and immune_to_melee:
		# Melee passes through (ghost)
		return
	
	hp -= damage
	_flash_damage()
	_spawn_damage_number(damage)
	
	if hp <= 0:
		die()

func _flash_damage() -> void:
	# Flash blanco por 0.1s al recibir daño (sobreexponemos modulate a blanco puro)
	var sprite := $Sprite2D
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(5.0, 5.0, 5.0, 1.0), 0.0)
	tween.tween_interval(0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.05)

func _spawn_damage_number(damage: int) -> void:
	var label: Node = DamageNumber.instantiate()
	get_parent().add_child(label)
	label.global_position = global_position + Vector2(randf_range(-10, 10), -20)
	if label.has_method("setup"):
		label.setup(damage)

func die() -> void:
	died.emit(xp_value)
	_play_death_effect()

func _play_death_effect() -> void:
	# Pop hacia arriba, luego scale down + fade out
	set_physics_process(false)
	set_process(false)
	var sprite := $Sprite2D
	var original_scale := sprite.scale
	var tween := create_tween()
	# Pequeño pop hacia arriba
	tween.tween_property(sprite, "position:y", sprite.position.y - 12.0, 0.08) \
		.set_ease(Tween.EASE_OUT)
	# Scale up leve (pop)
	tween.parallel().tween_property(sprite, "scale", original_scale * 1.25, 0.08) \
		.set_ease(Tween.EASE_OUT)
	# Luego scale down + fade
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.14) \
		.set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.14)
	tween.tween_callback(queue_free)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Kill the player
		if body.has_method("die"):
			body.die()
