extends Control

signal retry_requested
signal menu_requested

func _ready() -> void:
	# Set up labels
	$Panel/VBoxContainer/SessionXPLabel.text = "Session XP: %d" % GameManager.session_xp
	$Panel/VBoxContainer/TotalXPLabel.text = "Total XP: %d" % GameManager.total_xp

	var is_new_high := GameManager.session_xp >= GameManager.high_score and GameManager.session_xp > 0
	if is_new_high:
		$Panel/VBoxContainer/HighScoreLabel.text = "🏆 NEW HIGH SCORE!"
		$Panel/VBoxContainer/HighScoreLabel.add_theme_color_override("font_color", Color.GOLD)
	else:
		$Panel/VBoxContainer/HighScoreLabel.text = "High Score: %d" % GameManager.high_score

	$Panel/VBoxContainer/RetryButton.pressed.connect(_on_retry)
	$Panel/VBoxContainer/MenuButton.pressed.connect(_on_menu)

	# Entry animation
	_animate_entry(is_new_high)

func _animate_entry(is_new_high: bool) -> void:
	# Start panel scaled down and transparent
	$Panel.scale = Vector2(0.8, 0.8)
	$Panel.modulate.a = 0.0
	$DimBackground.modulate.a = 0.0

	var tween := create_tween()
	tween.set_parallel(true)
	
	# Fade in background
	tween.tween_property($DimBackground, "modulate:a", 1.0, 0.3)
	
	# Scale and fade panel
	tween.tween_property($Panel, "scale", Vector2(1.0, 1.0), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property($Panel, "modulate:a", 1.0, 0.3)

	# If new high score, add a bounce effect
	if is_new_high:
		await tween.finished
		var bounce := create_tween()
		bounce.tween_property($Panel/VBoxContainer/HighScoreLabel, "scale", Vector2(1.2, 1.2), 0.15)
		bounce.tween_property($Panel/VBoxContainer/HighScoreLabel, "scale", Vector2(1.0, 1.0), 0.15)

func _on_retry() -> void:
	_animate_exit(func(): retry_requested.emit(); queue_free())

func _on_menu() -> void:
	_animate_exit(func(): menu_requested.emit(); queue_free())

func _animate_exit(callback: Callable) -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property($Panel, "scale", Vector2(0.9, 0.9), 0.2)
	tween.tween_property($Panel, "modulate:a", 0.0, 0.2)
	tween.tween_property($DimBackground, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(callback)
