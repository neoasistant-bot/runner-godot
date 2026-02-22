extends Node2D

@export var obstacle_scene: PackedScene

var _level_data: LevelData
var _viewport_size: Vector2
var _distance_since_last: float = 0.0
var _next_spawn_distance: float = 0.0
var _obstacles: Array[Area2D] = []
var _is_active: bool = false
var _current_min_gap: float = 400.0
var _current_max_gap: float = 700.0

func configure(data: LevelData) -> void:
	_level_data = data
	_viewport_size = get_viewport_rect().size
	_current_min_gap = data.obstacle_min_gap
	_current_max_gap = GameManager.calculate_obstacle_gap(data.obstacle_min_gap, data.obstacle_max_gap)
	_next_spawn_distance = randf_range(_current_min_gap, _current_max_gap)
	_distance_since_last = 0.0

func start() -> void:
	_is_active = true

func stop() -> void:
	_is_active = false

func scroll(movement: Vector2) -> void:
	# Always move existing obstacles, even when spawning is stopped
	var to_remove: Array[int] = []
	for i in _obstacles.size():
		_obstacles[i].position += movement
		if _is_off_screen(_obstacles[i]):
			to_remove.append(i)

	# Remove off-screen (reverse order)
	for i in range(to_remove.size() - 1, -1, -1):
		_obstacles[to_remove[i]].queue_free()
		_obstacles.remove_at(to_remove[i])

	# Only accumulate distance and spawn when active
	if not _is_active:
		return

	_distance_since_last += movement.length()

	if _distance_since_last >= _next_spawn_distance:
		_spawn_obstacle()
		_distance_since_last = 0.0
		_next_spawn_distance = randf_range(_current_min_gap, _current_max_gap)

func _spawn_obstacle() -> void:
	if not obstacle_scene:
		return

	var obs: Area2D = obstacle_scene.instantiate()
	var spawn_pos: Vector2 = _calculate_spawn_position()
	obs.position = spawn_pos
	obs.setup(_level_data.obstacle_color, Vector2(64, 64))

	_obstacles.append(obs)
	add_child(obs)

func _calculate_spawn_position() -> Vector2:
	var spawn_offset: Vector2 = _level_data.get_spawn_offset(_viewport_size)

	if _level_data.is_horizontal():
		var ground_y: float = _viewport_size.y - 130.0
		var aerial_y: float = _viewport_size.y - 200.0
		var is_aerial: bool = randf() > 0.65
		var y_pos: float = aerial_y if is_aerial else ground_y
		return Vector2(spawn_offset.x, y_pos)
	else:
		var lane_x: float = [-150.0, 0.0, 150.0].pick_random()
		lane_x += _viewport_size.x / 2.0
		return Vector2(lane_x, spawn_offset.y)

func _is_off_screen(obs: Area2D) -> bool:
	var axis: String = _level_data.get_scroll_axis()
	var threshold: float = _level_data.get_destroy_threshold(_viewport_size)

	if axis == "x":
		if _level_data.scroll_direction.x > 0:
			return obs.position.x < threshold
		else:
			return obs.position.x > threshold
	else:
		if _level_data.scroll_direction.y > 0:
			return obs.position.y < threshold
		else:
			return obs.position.y > threshold
