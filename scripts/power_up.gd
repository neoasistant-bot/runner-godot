extends Area2D
class_name PowerUp

@export var power_up_type: String = "attack_speed"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_animate_idle()

func _animate_idle() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - 8.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y, 0.6).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		PowerUpManager.activate(power_up_type)
		queue_free()
