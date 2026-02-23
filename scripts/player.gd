extends CharacterBody2D

const GRAVITY_FORCE: float = 1200.0
const JUMP_VELOCITY: float = -500.0
const CROUCH_DURATION: float = 1.0
const LANE_OFFSETS: Array[float] = [-150.0, 0.0, 150.0]
const LANE_TWEEN_SPEED: float = 0.15
const SPRITE_STAND_SCALE: Vector2 = Vector2(4, 4)
const SPRITE_CROUCH_SCALE: Vector2 = Vector2(4, 2)

enum Mode { HORIZONTAL, VERTICAL }
enum State { RUNNING, JUMPING, CROUCHING, DODGING, DEAD }

var mode: Mode = Mode.HORIZONTAL
var current_state: State = State.RUNNING
var level_data: LevelData

var _crouch_timer: float = 0.0
var _current_lane: int = 1
var _lane_center_x: float = 0.0
var _dodge_positive_connected: bool = false
var _dodge_negative_connected: bool = false

func configure(data: LevelData) -> void:
	level_data = data
	if data.is_horizontal():
		mode = Mode.HORIZONTAL
		_connect_horizontal_input()
	else:
		mode = Mode.VERTICAL
		_lane_center_x = position.x
		_current_lane = 1
		_connect_vertical_input()

func _connect_horizontal_input() -> void:
	if not _dodge_positive_connected:
		SwipeDetector.swiped_up.connect(_on_dodge_positive)
		SwipeDetector.swiped_down.connect(_on_dodge_negative)
		_dodge_positive_connected = true
		_dodge_negative_connected = true

func _connect_vertical_input() -> void:
	if not _dodge_positive_connected:
		SwipeDetector.swiped_right.connect(_on_dodge_positive)
		SwipeDetector.swiped_left.connect(_on_dodge_negative)
		_dodge_positive_connected = true
		_dodge_negative_connected = true

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	match mode:
		Mode.HORIZONTAL:
			_process_horizontal(delta)
			move_and_slide()
		Mode.VERTICAL:
			_process_vertical(delta)
			# No move_and_slide() in vertical mode — player moves via Tween only
			# Obstacle detection uses HitboxArea (Area2D), not CharacterBody2D

func _process_horizontal(delta: float) -> void:
	if level_data and level_data.gravity_enabled and not is_on_floor():
		velocity.y += GRAVITY_FORCE * delta

	if current_state == State.CROUCHING:
		_crouch_timer -= delta
		if _crouch_timer <= 0:
			_stand_up()

	if current_state == State.JUMPING and is_on_floor():
		current_state = State.RUNNING

func _process_vertical(_delta: float) -> void:
	pass

func _on_dodge_positive() -> void:
	if current_state == State.DEAD:
		return
	match mode:
		Mode.HORIZONTAL:
			_jump()
		Mode.VERTICAL:
			_move_to_lane(_current_lane + 1)

func _on_dodge_negative() -> void:
	if current_state == State.DEAD:
		return
	match mode:
		Mode.HORIZONTAL:
			_crouch()
		Mode.VERTICAL:
			_move_to_lane(_current_lane - 1)

func _jump() -> void:
	if is_on_floor() and current_state != State.CROUCHING:
		velocity.y = JUMP_VELOCITY
		current_state = State.JUMPING

func _crouch() -> void:
	if is_on_floor() and current_state == State.RUNNING:
		current_state = State.CROUCHING
		_crouch_timer = CROUCH_DURATION
		# Visual feedback: squish the sprite vertically
		$Sprite2D.scale = SPRITE_CROUCH_SCALE
		$Sprite2D.position.y = 18.0
		# Swap collision shapes
		$StandingCollision.disabled = true
		$CrouchingCollision.disabled = false
		$HitboxArea/HitboxStanding.disabled = true
		$HitboxArea/HitboxCrouching.disabled = false

func _stand_up() -> void:
	current_state = State.RUNNING
	# Restore sprite
	$Sprite2D.scale = SPRITE_STAND_SCALE
	$Sprite2D.position.y = 0.0
	# Restore collision shapes
	$StandingCollision.disabled = false
	$CrouchingCollision.disabled = true
	$HitboxArea/HitboxStanding.disabled = false
	$HitboxArea/HitboxCrouching.disabled = true

func _move_to_lane(target_lane: int) -> void:
	target_lane = clampi(target_lane, 0, LANE_OFFSETS.size() - 1)
	if target_lane == _current_lane:
		return
	_current_lane = target_lane
	current_state = State.DODGING

	# Lanes are relative offsets from the center position
	var target_x: float = _lane_center_x + LANE_OFFSETS[_current_lane]
	var tween := create_tween()
	tween.tween_property(self, "position:x", target_x, LANE_TWEEN_SPEED)
	tween.tween_callback(func(): current_state = State.RUNNING)

func die() -> void:
	if current_state == State.DEAD:
		return
	current_state = State.DEAD
	set_physics_process(false)
	_disconnect_all_signals()
	GameManager.end_game()

func _disconnect_all_signals() -> void:
	if _dodge_positive_connected:
		if mode == Mode.HORIZONTAL:
			if SwipeDetector.swiped_up.is_connected(_on_dodge_positive):
				SwipeDetector.swiped_up.disconnect(_on_dodge_positive)
			if SwipeDetector.swiped_down.is_connected(_on_dodge_negative):
				SwipeDetector.swiped_down.disconnect(_on_dodge_negative)
		else:
			if SwipeDetector.swiped_right.is_connected(_on_dodge_positive):
				SwipeDetector.swiped_right.disconnect(_on_dodge_positive)
			if SwipeDetector.swiped_left.is_connected(_on_dodge_negative):
				SwipeDetector.swiped_left.disconnect(_on_dodge_negative)
		_dodge_positive_connected = false
		_dodge_negative_connected = false

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacles"):
		die()
	elif area.is_in_group("coins"):
		area.collect()
		if level_data:
			GameManager.add_xp(level_data.coin_value)
