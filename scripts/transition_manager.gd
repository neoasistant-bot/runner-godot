extends Node

signal level_ready(level_data: LevelData)
signal transition_started
signal transition_finished

var available_levels: Array[LevelData] = []
var current_level_data: LevelData
var _current_index: int = -1

func _ready() -> void:
	available_levels = [
		preload("res://data/level_rio.tres"),
		preload("res://data/level_plataforma.tres"),
		preload("res://data/level_hellevator.tres"),
		preload("res://data/level_abduccion.tres"),
	]

## Pick next level in fixed sequence: Río → Plataforma → Hellevator → Abducción → (loop)
func pick_next_level() -> LevelData:
	_current_index = (_current_index + 1) % available_levels.size()
	current_level_data = available_levels[_current_index]
	return current_level_data

## Start transition to the next level (with timing for fade effect)
func transition_to_next() -> void:
	transition_started.emit()
	# Wait for fade-out animation in Main (0.4s) before swapping level
	await get_tree().create_timer(0.4).timeout
	var next_data: LevelData = pick_next_level()
	level_ready.emit(next_data)
	# Give Main a frame to set up the new level, then signal fade-in
	await get_tree().process_frame
	transition_finished.emit()

## Start the first level (Río, no transition animation)
func start_first_level() -> void:
	var data: LevelData = pick_next_level()
	level_ready.emit(data)
