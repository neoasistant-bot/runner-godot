extends Node2D
class_name DamageNumber

# Muestra un número de daño flotante que sube y desaparece.
# Llamar setup(damage) después de instanciar y posicionar.

@onready var label: Label = $Label

const RISE_DISTANCE: float = 40.0
const DURATION: float = 0.65

func setup(damage: int) -> void:
	label.text = "−%d" % damage
	var tween := create_tween()
	# Sube
	tween.tween_property(self, "position:y", position.y - RISE_DISTANCE, DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	# Fade out en la segunda mitad
	tween.parallel().tween_property(label, "modulate:a", 0.0, DURATION * 0.5) \
		.set_ease(Tween.EASE_IN).set_delay(DURATION * 0.5)
	tween.tween_callback(queue_free)
