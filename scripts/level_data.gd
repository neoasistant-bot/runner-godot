class_name LevelData
extends Resource

@export var level_name: String = ""
@export var scroll_direction: Vector2 = Vector2(1, 0)
@export var dodge_direction: Vector2 = Vector2(0, -1)
@export var base_speed: float = 300.0
@export var base_distance: float = 2000.0
@export var distance_scale_per_xp: float = 5.0
@export var gravity_enabled: bool = true
@export var gravity_direction: Vector2 = Vector2(0, 1)
@export var coin_frequency: float = 200.0
@export var coin_value: int = 10
@export var obstacle_min_gap: float = 400.0
@export var obstacle_max_gap: float = 700.0
@export var ground_color: Color = Color.DARK_GREEN
@export var bg_color: Color = Color.CORNFLOWER_BLUE
@export var obstacle_color: Color = Color.RED
@export var level_complete_bonus: int = 50

## Returns true if this is a horizontal-scrolling level
func is_horizontal() -> bool:
	return scroll_direction.x != 0.0

## Returns the spawn edge position (where new objects appear)
func get_spawn_offset(viewport_size: Vector2) -> Vector2:
	if scroll_direction == Vector2(1, 0):
		return Vector2(viewport_size.x + 100, 0)
	elif scroll_direction == Vector2(-1, 0):
		return Vector2(-100, 0)
	elif scroll_direction == Vector2(0, 1):
		return Vector2(0, viewport_size.y + 100)
	elif scroll_direction == Vector2(0, -1):
		return Vector2(0, -100)
	return Vector2.ZERO

## Returns the destroy threshold (where objects get cleaned up)
func get_destroy_threshold(viewport_size: Vector2) -> float:
	if scroll_direction == Vector2(1, 0):
		return -100.0
	elif scroll_direction == Vector2(-1, 0):
		return viewport_size.x + 100.0
	elif scroll_direction == Vector2(0, 1):
		return -100.0
	elif scroll_direction == Vector2(0, -1):
		return viewport_size.y + 100.0
	return 0.0

## Returns which axis to check for destroy threshold
func get_scroll_axis() -> String:
	if scroll_direction.x != 0.0:
		return "x"
	return "y"
