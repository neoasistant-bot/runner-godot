extends Node

signal level_ready(level_data: LevelData)
signal transition_started
signal transition_finished

var available_levels: Array[LevelData] = []
var current_level_data: LevelData
var _last_level_index: int = -1

func _ready() -> void:
	available_levels = [
		preload("res://data/level_rio.tres"),
		preload("res://data/level_plataforma.tres"),
		preload("res://data/level_hellevator.tres"),
		preload("res://data/level_abduccion.tres"),
	]

## Pick a random level (not the same as the last one)
func pick_next_level() -> LevelData:
	var index: int = randi_range(0, available_levels.size() - 1)
	while index == _last_level_index and available_levels.size() > 1:
		index = randi_range(0, available_levels.size() - 1)
	_last_level_index = index
	current_level_data = available_levels[index]
	return current_level_data

## Start transition to a new level
func transition_to_next() -> void:
	transition_started.emit()
	var next_data: LevelData = pick_next_level()
	await get_tree().create_timer(0.5).timeout
	level_ready.emit(next_data)
	transition_finished.emit()

## Start the first level (no transition animation)
func start_first_level() -> void:
	var data: LevelData = pick_next_level()
	level_ready.emit(data)
