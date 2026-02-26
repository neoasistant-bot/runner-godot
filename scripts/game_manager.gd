extends Node

signal game_started
signal game_over
signal xp_changed(new_xp: int)
signal level_completed
signal phase_changed(new_phase: int)

enum State { MENU, PLAYING, DEAD }
enum DifficultyPhase {
	OBSTACLES_ONLY,  # 0   — solo bloques
	HAZARDS,         # 100 — + rayo/onda de choque
	ENEMIES,         # 250 — + Slime
	MIX_1,           # 500 — + Murciélago
	MIX_2,           # 900 — + Esqueleto
	FULL             # 1500 — todo + Fantasma
}

const SAVE_PATH: String = "user://savegame.save"
const DEATH_PENALTY: float = 0.20

var state: State = State.MENU
var total_xp: int = 0
var session_xp: int = 0
var high_score: int = 0
var levels_completed: int = 0
var _current_phase: int = DifficultyPhase.OBSTACLES_ONLY

const PHASE_THRESHOLDS: Array[int] = [0, 10, 25, 60, 150, 300]

func _ready() -> void:
	load_data()

## Start a new game session
func start_game() -> void:
	session_xp = 0
	state = State.PLAYING
	game_started.emit()

## End the game (player died)
func end_game() -> void:
	state = State.DEAD
	var penalty: int = int(total_xp * DEATH_PENALTY)
	total_xp = max(0, total_xp - penalty)
	if session_xp > high_score:
		high_score = session_xp
	save_data()
	game_over.emit()

## Player collected a coin
func add_xp(value: int) -> void:
	total_xp += value
	session_xp += value
	xp_changed.emit(total_xp)
	_check_phase_change()

## Player completed a level (touched teleporter)
func complete_level(bonus: int) -> void:
	total_xp += bonus
	session_xp += bonus
	levels_completed += 1
	xp_changed.emit(total_xp)
	level_completed.emit()

## Get current difficulty level (every 100 XP = 1 level)
func get_difficulty_level() -> int:
	return total_xp / 100

## Get current difficulty phase based on total XP
func get_phase() -> int:
	var phase: int = DifficultyPhase.OBSTACLES_ONLY
	for i: int in range(PHASE_THRESHOLDS.size()):
		if total_xp >= PHASE_THRESHOLDS[i]:
			phase = i
	return phase

## Check and emit phase_changed if phase advanced
func _check_phase_change() -> void:
	var new_phase: int = get_phase()
	if new_phase != _current_phase:
		_current_phase = new_phase
		phase_changed.emit(_current_phase)

## Calculate level distance based on XP
func calculate_level_distance(base: float, scale: float) -> float:
	return base + (get_difficulty_level() * scale)

## Calculate scroll speed based on XP
func calculate_speed(base: float) -> float:
	return base + (get_difficulty_level() * 15.0)

## Calculate obstacle gap based on XP
func calculate_obstacle_gap(min_gap: float, max_gap: float) -> float:
	var reduction: float = get_difficulty_level() * 10.0
	return max(min_gap, max_gap - reduction)

## Save XP and stats to disk
func save_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var({
			"total_xp": total_xp,
			"high_score": high_score,
			"levels_completed": levels_completed,
		})

## Load XP and stats from disk
func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var data: Variant = file.get_var()
		if data is Dictionary:
			total_xp = data.get("total_xp", 0)
			high_score = data.get("high_score", 0)
			levels_completed = data.get("levels_completed", 0)
