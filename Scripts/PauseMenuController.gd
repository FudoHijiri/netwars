extends CanvasLayer

signal resume_requested
signal quit_requested

func _ready() -> void:
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = false
		queue_free()
		get_tree().root.set_input_as_handled()

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_settings_button_pressed() -> void:
	queue_free()
	MenuManager.go_to_settings()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	queue_free()
	MenuManager.go_to_main_menu()
