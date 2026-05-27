extends Node

func _ready() -> void:
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_open_pause_menu()
		get_tree().root.set_input_as_handled()

func _open_pause_menu() -> void:
	var pause_menu = preload("res://Scenes/PauseMenu.tscn").instantiate()
	get_tree().root.add_child(pause_menu)
