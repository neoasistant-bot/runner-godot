extends Area2D

signal activated

var _level_data: LevelData

func configure(data: LevelData) -> void:
	_level_data = data
	var viewport_size: Vector2 = get_viewport_rect().size

	if data.is_horizontal():
		$ColorRect.size = Vector2(64, 200)
		$ColorRect.position = Vector2(-32, -100)
		$CollisionShape2D.shape = RectangleShape2D.new()
		$CollisionShape2D.shape.size = Vector2(60, 196)
	else:
		$ColorRect.size = Vector2(400, 64)
		$ColorRect.position = Vector2(-200, -32)
		$CollisionShape2D.shape = RectangleShape2D.new()
		$CollisionShape2D.shape.size = Vector2(396, 60)

## Move with the world scroll so the player can reach us
func scroll(movement: Vector2) -> void:
	position += movement

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		activated.emit()
