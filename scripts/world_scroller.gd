extends Node2D

signal distance_updated(total: float)

var scroll_vector: Vector2 = Vector2.ZERO
var current_speed: float = 0.0
var distance_traveled: float = 0.0
var _is_running: bool = false
var _debug_frames: int = 0

func configure(data: LevelData) -> void:
	scroll_vector = -data.scroll_direction
	current_speed = GameManager.calculate_speed(data.base_speed)
	distance_traveled = 0.0
	print("[WorldScroller] configure: scroll_vector=%s speed=%.1f direction=%s" % [
		str(scroll_vector), current_speed, str(data.scroll_direction)
	])

func start() -> void:
	_is_running = true
	print("[WorldScroller] start: _is_running=true")

func stop() -> void:
	_is_running = false

func _process(delta: float) -> void:
	if not _is_running:
		return

	var movement: Vector2 = scroll_vector * current_speed * delta
	distance_traveled += current_speed * delta

	_debug_frames += 1
	if _debug_frames <= 5 or _debug_frames % 300 == 0:
		var scroll_children: int = 0
		for child in get_children():
			if child.has_method("scroll"):
				scroll_children += 1
		print("[WorldScroller] frame=%d movement=%s dist=%.0f scroll_children=%d" % [
			_debug_frames, str(movement), distance_traveled, scroll_children
		])

	for child in get_children():
		if child.has_method("scroll"):
			child.scroll(movement)

	distance_updated.emit(distance_traveled)
