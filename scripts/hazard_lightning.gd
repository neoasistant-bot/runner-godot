extends Area2D
class_name HazardLightning

## Lightning hazard — esquivable pero no destruible.
## Warning de 0.8s con parpadeo semitransparente, luego hitbox activa 0.3s.

const WARNING_DURATION: float = 0.8
const ACTIVE_DURATION: float = 0.3
const BLINK_SPEED: float = 0.1

enum Phase { WARNING, ACTIVE, DONE }

var _phase: Phase = Phase.WARNING
var _timer: float = 0.0
var _blink_timer: float = 0.0
var _blink_state: bool = true

@onready var sprite: ColorRect = $Sprite
@onready var hitbox: CollisionShape2D = $HitboxShape

func _ready() -> void:
	# Empieza en fase warning — sin hitbox, semitransparente parpadeando
	add_to_group("hazards")
	hitbox.disabled = true
	modulate.a = 0.4
	monitoring = false
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_timer += delta

	match _phase:
		Phase.WARNING:
			# Parpadeo
			_blink_timer += delta
			if _blink_timer >= BLINK_SPEED:
				_blink_timer = 0.0
				_blink_state = !_blink_state
				modulate.a = 0.5 if _blink_state else 0.15

			if _timer >= WARNING_DURATION:
				_activate()

		Phase.ACTIVE:
			if _timer >= ACTIVE_DURATION:
				_deactivate()

		Phase.DONE:
			pass

func _activate() -> void:
	_phase = Phase.ACTIVE
	_timer = 0.0
	modulate.a = 1.0
	hitbox.disabled = false
	monitoring = true
	# Efecto visual: flash brillante
	sprite.color = Color(0.9, 0.95, 1.0, 1.0)

func _deactivate() -> void:
	_phase = Phase.DONE
	hitbox.disabled = true
	monitoring = false
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("die"):
			body.die()

# Los hazards NO reciben daño — ignorar cualquier colisión con proyectiles/melee
func take_damage(_amount: int) -> void:
	pass
