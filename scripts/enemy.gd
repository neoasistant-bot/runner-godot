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
	
	if hp <= 0:
		die()

func _flash_damage() -> void:
	# Visual feedback
	var sprite := $Sprite2D
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.05)

func die() -> void:
	died.emit(xp_value)
	_play_death_effect()
	queue_free()

func _play_death_effect() -> void:
	# Simple scale down + fade
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property($Sprite2D, "scale", Vector2.ZERO, 0.15)
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.15)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Kill the player
		if body.has_method("die"):
			body.die()
