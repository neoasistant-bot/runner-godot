extends CharacterBody2D

const GRAVITY: float = 1200.0

func _physics_process(delta: float) -> void:
	# Aplicar gravedad si no esta en el piso
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	move_and_slide()
