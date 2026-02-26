extends Area2D
class_name HazardShockwave

## Shockwave hazard — viaja horizontalmente a baja altura.
## Warning de 0.5s (línea en el suelo), luego la onda se desplaza.
## Player debe SALTAR para esquivarlo.

const WARNING_DURATION: float = 0.5
const TRAVEL_SPEED: float = 600.0    # px/s horizontalmente
const WAVE_LIFETIME: float = 3.0     # se destruye si no sale de pantalla antes

enum Phase { WARNING, TRAVELING, DONE }

var _phase: Phase = Phase.WARNING
var _timer: float = 0.0
var _direction: float = -1.0         # -1 = izquierda, +1 = derecha
var _viewport_width: float = 1920.0

@onready var body_rect: ColorRect = $Body
@onready var warning_line: ColorRect = $WarningLine
@onready var hitbox: CollisionShape2D = $HitboxShape

func configure(dir: float, vp_width: float) -> void:
	_direction = dir
	_viewport_width = vp_width

func _ready() -> void:
	add_to_group("hazards")
	hitbox.disabled = true
	monitoring = false
	body_rect.visible = false
	warning_line.visible = true
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_timer += delta

	match _phase:
		Phase.WARNING:
			# Pulsa la línea de warning
			var pulse := abs(sin(_timer * 10.0))
			warning_line.modulate.a = 0.4 + 0.6 * pulse

			if _timer >= WARNING_DURATION:
				_start_travel()

		Phase.TRAVELING:
			position.x += TRAVEL_SPEED * _direction * delta

			# Destruir cuando sale de pantalla
			if _direction < 0 and position.x < -200:
				_finish()
			elif _direction > 0 and position.x > _viewport_width + 200:
				_finish()

			if _timer >= WAVE_LIFETIME:
				_finish()

		Phase.DONE:
			pass

func _start_travel() -> void:
	_phase = Phase.TRAVELING
	_timer = 0.0
	warning_line.visible = false
	body_rect.visible = true
	hitbox.disabled = false
	monitoring = true

func _finish() -> void:
	_phase = Phase.DONE
	hitbox.disabled = true
	monitoring = false
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("die"):
			body.die()

# Los hazards NO reciben daño
func take_damage(_amount: int) -> void:
	pass
