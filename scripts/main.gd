extends Node2D

const LEVEL_SCENE: PackedScene = preload("res://scenes/level.tscn")

@onready var level_container: Node2D = $LevelContainer
@onready var ui_overlay: CanvasLayer = $UIOverlay

var _current_level: Node2D

func _ready() -> void:
	TransitionManager.level_ready.connect(_on_level_ready)
	GameManager.game_over.connect(_on_game_over)
	# Auto-start when Main scene loads (coming from menu)
	start_game()

func start_game() -> void:
	# Clear any existing UI overlays
	for child in ui_overlay.get_children():
		child.queue_free()

	GameManager.start_game()
	TransitionManager.start_first_level()

func _on_level_ready(data: LevelData) -> void:
	# Remove old level
	if _current_level:
		_current_level.queue_free()
		await get_tree().process_frame

	# Instantiate new level
	_current_level = LEVEL_SCENE.instantiate()
	_current_level.configure(data)
	level_container.add_child(_current_level)

func _on_game_over() -> void:
	# Show game over screen after a brief delay
	await get_tree().create_timer(1.0).timeout
	var game_over_scene = load("res://scenes/game_over.tscn")
	if game_over_scene:
		var game_over_screen = game_over_scene.instantiate()
		game_over_screen.retry_requested.connect(_on_retry)
		game_over_screen.menu_requested.connect(_on_menu)
		ui_overlay.add_child(game_over_screen)
	else:
		print("[Main] Game Over screen not found — will be added in T16")

func _on_retry() -> void:
	start_game()

func _on_menu() -> void:
	var menu_scene = load("res://scenes/main_menu.tscn")
	if menu_scene:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		print("[Main] Main Menu scene not found — will be added in T15")
