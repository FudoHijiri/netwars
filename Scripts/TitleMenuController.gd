extends Node2D

func _ready() -> void:
	get_tree().paused = false

	$CenterContainer/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$CenterContainer/VBoxContainer/LoginButton.pressed.connect(_on_login_pressed)
	$CenterContainer/VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$CenterContainer/VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)

func _on_play_pressed() -> void:
	MenuManager.go_to_play_selection()

func _on_login_pressed() -> void:
	MenuManager.go_to_login()

func _on_settings_pressed() -> void:
	MenuManager.go_to_settings()

func _on_exit_pressed() -> void:
	MenuManager.exit_game()
