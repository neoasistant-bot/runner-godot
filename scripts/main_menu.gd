extends Control

func _ready() -> void:
	$VBoxContainer/XPLabel.text = "XP: %d" % GameManager.total_xp
	$VBoxContainer/HighScoreLabel.text = "High Score: %d" % GameManager.high_score
	$VBoxContainer/PlayButton.pressed.connect(_on_play)

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
