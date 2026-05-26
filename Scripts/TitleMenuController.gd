extends Node2D

func _ready():
	get_tree().paused = false
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($Title, "modulate:a", 1.0, 0.5)
	tween.tween_property($Subtitle, "modulate:a", 1.0, 0.7)
	tween.tween_property($PressAnyKey, "modulate:a", 1.0, 0.9)

	$BlinkTimer.timeout.connect(_on_blink_timer_timeout)
	$BlinkTimer.start()

func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		get_tree().root.set_input_as_handled()
		MenuManager.go_to_main_menu()

func _on_blink_timer_timeout():
	var press_key_label = $PressAnyKey
	press_key_label.modulate.a = 0.5 if press_key_label.modulate.a > 0.7 else 1.0
