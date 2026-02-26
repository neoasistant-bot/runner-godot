extends Area2D

func _ready() -> void:
	add_to_group("obstacles")

func setup(_color: Color, obs_size: Vector2) -> void:
	# Note: ColorRect was replaced with Sprite2D (Kenney assets)
	# Color parameter kept for API compatibility but not used
	
	# Update collision to match size
	if $CollisionShape2D.shape == null:
		$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.size = obs_size - Vector2(4, 4)
	
	# Scale sprite to match desired size (base sprite is ~16x16)
	if has_node("Sprite2D"):
		var sprite = $Sprite2D
		var base_size = sprite.texture.get_size() if sprite.texture else Vector2(16, 16)
		sprite.scale = obs_size / base_size
