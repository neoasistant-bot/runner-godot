extends Enemy
class_name EnemyBat

## Bat moves in a zigzag pattern

var _zigzag_timer: float = 0.0
var _zigzag_direction: float = 1.0
const ZIGZAG_INTERVAL: float = 0.5
const ZIGZAG_AMPLITUDE: float = 100.0

func _physics_process(delta: float) -> void:
	# Base movement towards player
	position += _move_direction * speed * delta
	
	# Zigzag perpendicular to move direction
	_zigzag_timer += delta
	if _zigzag_timer >= ZIGZAG_INTERVAL:
		_zigzag_timer = 0.0
		_zigzag_direction *= -1.0
	
	var perpendicular := Vector2(-_move_direction.y, _move_direction.x)
	position += perpendicular * _zigzag_direction * ZIGZAG_AMPLITUDE * delta
	
	_check_bounds()
