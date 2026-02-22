extends Node2D

@export var coin_scene: PackedScene

var _level_data: LevelData
var _viewport_size: Vector2
var _distance_since_last: float = 0.0
var _next_spawn_distance: float = 0.0
var _coins: Array[Area2D] = []
var _is_active: bool = false

func configure(data: LevelData) -> void:
	_level_data = data
	_viewport_size = get_viewport_rect().size
	_next_spawn_distance = randf_range(data.coin_frequency * 0.5, data.coin_frequency * 1.5)
	_distance_since_last = 0.0

func start() -> void:
	_is_active = true

func stop() -> void:
	_is_active = false

func scroll(movement: Vector2) -> void:
	# Always move existing coins, even when spawning is stopped
	var to_remove: Array[int] = []
	for i in _coins.size():
		if is_instance_valid(_coins[i]):
			_coins[i].position += movement
			if _is_off_screen(_coins[i]):
				to_remove.append(i)
		else:
			to_remove.append(i)

	for i in range(to_remove.size() - 1, -1, -1):
		if is_instance_valid(_coins[to_remove[i]]):
			_coins[to_remove[i]].queue_free()
		_coins.remove_at(to_remove[i])

	# Only accumulate distance and spawn when active
	if not _is_active:
		return

	_distance_since_last += movement.length()

	if _distance_since_last >= _next_spawn_distance:
		_spawn_coin()
		_distance_since_last = 0.0
		_next_spawn_distance = randf_range(
			_level_data.coin_frequency * 0.5,
			_level_data.coin_frequency * 1.5
		)

func _spawn_coin() -> void:
	if not coin_scene:
		return

	var coin: Area2D = coin_scene.instantiate()
	var spawn_offset: Vector2 = _level_data.get_spawn_offset(_viewport_size)

	if _level_data.is_horizontal():
		var y_pos: float = randf_range(_viewport_size.y - 250.0, _viewport_size.y - 120.0)
		coin.position = Vector2(spawn_offset.x, y_pos)
	else:
		var lane_x: float = [-150.0, 0.0, 150.0].pick_random()
		lane_x += _viewport_size.x / 2.0
		coin.position = Vector2(lane_x, spawn_offset.y)

	_coins.append(coin)
	add_child(coin)

func _is_off_screen(coin: Area2D) -> bool:
	var axis: String = _level_data.get_scroll_axis()
	var threshold: float = _level_data.get_destroy_threshold(_viewport_size)

	if axis == "x":
		if _level_data.scroll_direction.x > 0:
			return coin.position.x < threshold
		else:
			return coin.position.x > threshold
	else:
		if _level_data.scroll_direction.y > 0:
			return coin.position.y < threshold
		else:
			return coin.position.y > threshold
