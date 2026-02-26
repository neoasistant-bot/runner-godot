extends Area2D
class_name Projectile

const DAMAGE: int = 1
const SPEED: float = 800.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta
	_check_bounds()

func _check_bounds() -> void:
	var viewport_size := get_viewport_rect().size
	if position.x < -50 or position.x > viewport_size.x + 50:
		queue_free()
	if position.y < -50 or position.y > viewport_size.y + 50:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies") and area.has_method("take_damage"):
		area.take_damage(DAMAGE, false)  # false = ranged
		_play_hit_effect()
		queue_free()

func _play_hit_effect() -> void:
	# Could spawn a hit particle here
	pass
