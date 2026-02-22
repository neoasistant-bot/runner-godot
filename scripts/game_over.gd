extends Control

signal retry_requested
signal menu_requested

func _ready() -> void:
	$Panel/VBoxContainer/SessionXPLabel.text = "Session XP: %d" % GameManager.session_xp
	$Panel/VBoxContainer/TotalXPLabel.text = "Total XP: %d" % GameManager.total_xp

	if GameManager.session_xp >= GameManager.high_score and GameManager.session_xp > 0:
		$Panel/VBoxContainer/HighScoreLabel.text = "NEW HIGH SCORE!"
	else:
		$Panel/VBoxContainer/HighScoreLabel.text = "High Score: %d" % GameManager.high_score

	$Panel/VBoxContainer/RetryButton.pressed.connect(_on_retry)
	$Panel/VBoxContainer/MenuButton.pressed.connect(_on_menu)

func _on_retry() -> void:
	retry_requested.emit()
	queue_free()

func _on_menu() -> void:
	menu_requested.emit()
	queue_free()
