extends Node

signal swiped_up
signal swiped_down
signal swiped_left
signal swiped_right

const SWIPE_THRESHOLD: float = 50.0
const TAP_THRESHOLD: float = 20.0

var _touch_start: Vector2 = Vector2.ZERO
var _touch_start_time: int = 0
var _is_touching: bool = false

func _input(event: InputEvent) -> void:
	# Touch input
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_start = event.position
			_touch_start_time = Time.get_ticks_msec()
			_is_touching = true
		elif _is_touching:
			_process_gesture(event.position)
			_is_touching = false

	# Keyboard fallback
	if event.is_action_pressed("move_up"):
		swiped_up.emit()
	elif event.is_action_pressed("move_down"):
		swiped_down.emit()
	elif event.is_action_pressed("move_left"):
		swiped_left.emit()
	elif event.is_action_pressed("move_right"):
		swiped_right.emit()

func _process_gesture(end_pos: Vector2) -> void:
	var diff: Vector2 = end_pos - _touch_start

	if diff.length() < TAP_THRESHOLD:
		return

	if diff.length() < SWIPE_THRESHOLD:
		return

	# Determine dominant axis
	if abs(diff.x) > abs(diff.y):
		# Horizontal swipe
		if diff.x > 0:
			swiped_right.emit()
		else:
			swiped_left.emit()
	else:
		# Vertical swipe
		if diff.y < 0:
			swiped_up.emit()
		else:
			swiped_down.emit()
