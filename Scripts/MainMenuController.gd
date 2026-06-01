extends Node2D

func _ready() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($PlayButton, "modulate:a", 1.0, 0.3)
	tween.tween_property($SettingsButton, "modulate:a", 1.0, 0.4)
	tween.tween_property($ExitButton, "modulate:a", 1.0, 0.5)

func _on_play_button_pressed() -> void:
	get_tree().paused = false
	MenuManager.current_menu_node.queue_free()
	MenuManager.current_menu_node = null

func _on_settings_button_pressed() -> void:
	MenuManager.go_to_settings()

func _on_exit_button_pressed() -> void:
	MenuManager.is_pause_menu = false
	MenuManager.go_to_title_menu()
