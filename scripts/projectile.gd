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

var _hits_remaining: int = 1

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	# Laser: atraviesa hasta 3 enemigos
	if PowerUpManager.is_active("laser"):
		_hits_remaining = 3
		modulate = Color(0.2, 1.0, 1.0)  # cyan

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies") and area.has_method("take_damage"):
		area.take_damage(DAMAGE, false)
		_hits_remaining -= 1
		if _hits_remaining <= 0:
			queue_free()
