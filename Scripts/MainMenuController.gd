extends Node2D

func _ready():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($PlayButton, "modulate:a", 1.0, 0.3)
	tween.tween_property($SettingsButton, "modulate:a", 1.0, 0.4)
	tween.tween_property($ExitButton, "modulate:a", 1.0, 0.5)

func _on_play_button_pressed():
	MenuManager.go_to_play_selection()

func _on_settings_button_pressed():
	MenuManager.load_menu("res://Scenes/Menus/SettingsMenu.tscn")

func _on_exit_button_pressed():
	MenuManager.exit_game()
