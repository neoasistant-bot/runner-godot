extends Area2D

signal activated

var _level_data: LevelData

func configure(data: LevelData) -> void:
	_level_data = data

	# Sizes for horizontal vs vertical levels
	var target_size: Vector2
	var collision_size: Vector2
	
	if data.is_horizontal():
		target_size = Vector2(64, 200)
		collision_size = Vector2(60, 196)
	else:
		target_size = Vector2(400, 64)
		collision_size = Vector2(396, 60)
	
	# Setup collision
	if $CollisionShape2D.shape == null:
		$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.size = collision_size
	
	# Scale sprite to match target size (Sprite2D replaced ColorRect)
	if has_node("Sprite2D"):
		var sprite = $Sprite2D
		var base_size = sprite.texture.get_size() if sprite.texture else Vector2(16, 16)
		sprite.scale = target_size / base_size

## Move with the world scroll so the player can reach us
func scroll(movement: Vector2) -> void:
	position += movement

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		activated.emit()
