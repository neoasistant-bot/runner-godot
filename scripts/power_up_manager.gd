extends Node

signal activated(type: String)
signal expired(type: String)

const DURATIONS: Dictionary = {
	"attack_speed": 10.0,
	"big_sword": 8.0,
	"laser": 12.0,
}

var _active_type: String = ""
var _timer: float = 0.0

func _process(delta: float) -> void:
	if _active_type.is_empty():
		return
	_timer -= delta
	if _timer <= 0.0:
		_expire()

func activate(type: String) -> void:
	if not _active_type.is_empty():
		expired.emit(_active_type)  # reemplaza el anterior
	_active_type = type
	_timer = DURATIONS.get(type, 10.0)
	activated.emit(_active_type)

func is_active(type: String) -> bool:
	return _active_type == type

func get_active_type() -> String:
	return _active_type

func get_remaining_ratio() -> float:
	if _active_type.is_empty():
		return 0.0
	return _timer / DURATIONS.get(_active_type, 10.0)

func _expire() -> void:
	var old: String = _active_type
	_active_type = ""
	_timer = 0.0
	expired.emit(old)
