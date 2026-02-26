extends Area2D

func _ready() -> void:
	add_to_group("coins")

func collect() -> void:
	queue_free()
