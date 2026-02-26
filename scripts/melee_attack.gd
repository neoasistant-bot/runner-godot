extends Area2D
class_name MeleeAttack

const DAMAGE: int = 2
const DURATION: float = 0.2

var _timer: float = 0.0

func _ready() -> void:
	# Connect to detect enemies
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= DURATION:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	_try_damage(body)

func _on_area_entered(area: Area2D) -> void:
	_try_damage(area)

func _try_damage(node: Node) -> void:
	if node.is_in_group("enemies") and node.has_method("take_damage"):
		node.take_damage(DAMAGE, true)  # true = melee
		_flash_hitbox()

func _flash_hitbox() -> void:
	# Flash amarillo/naranja en el hitbox al conectar
	var sprite := get_node_or_null("Sprite2D")
	if sprite == null:
		return
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 0.75, 0.0, 0.85), 0.0)
	tween.tween_interval(0.08)
	tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.07)
