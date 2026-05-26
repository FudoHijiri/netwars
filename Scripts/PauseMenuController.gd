extends CanvasLayer

signal resume_requested
signal quit_requested

func _ready() -> void:
	$PanelContainer/VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$PanelContainer/VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$PanelContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_resume_pressed() -> void:
	queue_free()

func _on_settings_pressed() -> void:
	pass

func _on_quit_pressed() -> void:
	queue_free()
	MenuManager.go_to_main_menu()
