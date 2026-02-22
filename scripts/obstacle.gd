extends Area2D

func _ready() -> void:
	add_to_group("obstacles")

func setup(color: Color, obs_size: Vector2) -> void:
	$ColorRect.color = color
	$ColorRect.size = obs_size
	$ColorRect.position = -obs_size / 2
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.size = obs_size - Vector2(4, 4)
