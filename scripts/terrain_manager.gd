extends Node2D

var _tiles: Array[ColorRect] = []
var _tile_size: float = 0.0
var _scroll_axis: String = "x"
var _level_data: LevelData
var _viewport_size: Vector2

func configure(data: LevelData) -> void:
	_level_data = data
	_viewport_size = get_viewport_rect().size
	_scroll_axis = data.get_scroll_axis()

	# Clear any existing tiles
	for tile in _tiles:
		tile.queue_free()
	_tiles.clear()

	if data.is_horizontal():
		_setup_horizontal_ground()
	else:
		_setup_vertical_walls()

func _setup_horizontal_ground() -> void:
	_tile_size = 128.0
	var ground_y: float = _viewport_size.y - 100.0
	var count: int = ceili(_viewport_size.x / _tile_size) + 3

	for i in count:
		var tile := ColorRect.new()
		tile.size = Vector2(_tile_size, 100.0)
		tile.color = _level_data.ground_color
		tile.position = Vector2(i * _tile_size, ground_y)
		_tiles.append(tile)
		add_child(tile)

func _setup_vertical_walls() -> void:
	_tile_size = 128.0
	var wall_width: float = 60.0
	var count: int = ceili(_viewport_size.y / _tile_size) + 3

	for i in count:
		# Left wall
		var left := ColorRect.new()
		left.size = Vector2(wall_width, _tile_size)
		left.color = _level_data.ground_color
		left.position = Vector2(0, i * _tile_size)
		_tiles.append(left)
		add_child(left)

		# Right wall
		var right := ColorRect.new()
		right.size = Vector2(wall_width, _tile_size)
		right.color = _level_data.ground_color
		right.position = Vector2(_viewport_size.x - wall_width, i * _tile_size)
		_tiles.append(right)
		add_child(right)

func scroll(movement: Vector2) -> void:
	for tile in _tiles:
		tile.position += movement

	_recycle_tiles()

func _recycle_tiles() -> void:
	if _level_data.is_horizontal():
		_recycle_horizontal()
	else:
		_recycle_vertical()

func _recycle_horizontal() -> void:
	var rightmost_x: float = _get_max_position("x")
	for tile in _tiles:
		if tile.position.x < -_tile_size:
			tile.position.x = rightmost_x + _tile_size
		elif tile.position.x > _viewport_size.x + _tile_size:
			var leftmost_x: float = _get_min_position("x")
			tile.position.x = leftmost_x - _tile_size

func _recycle_vertical() -> void:
	var bottommost_y: float = _get_max_position("y")
	for tile in _tiles:
		if tile.position.y < -_tile_size:
			tile.position.y = bottommost_y + _tile_size
		elif tile.position.y > _viewport_size.y + _tile_size:
			var topmost_y: float = _get_min_position("y")
			tile.position.y = topmost_y - _tile_size

func _get_max_position(axis: String) -> float:
	var max_val: float = -INF
	for tile in _tiles:
		var val: float = tile.position.x if axis == "x" else tile.position.y
		if val > max_val:
			max_val = val
	return max_val

func _get_min_position(axis: String) -> float:
	var min_val: float = INF
	for tile in _tiles:
		var val: float = tile.position.x if axis == "x" else tile.position.y
		if val < min_val:
			min_val = val
	return min_val
