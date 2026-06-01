extends CanvasLayer

signal resume_requested
signal quit_requested

var master_volume: int = 100
var selected_difficulty: String = "Medium"

func _ready() -> void:
	get_tree().paused = true
	$CenterContainer/SettingsPanel/SettingsVBox/VolumeSlider.value = master_volume
	_highlight_difficulty_button()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if $CenterContainer/SettingsPanel.visible:
			_show_settings(false)
		else:
			get_tree().paused = false
			queue_free()
		get_tree().root.set_input_as_handled()

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_settings_button_pressed() -> void:
	_show_settings(true)

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	queue_free()
	MenuManager.go_to_title_menu()

func _show_settings(visible: bool) -> void:
	$CenterContainer/PanelContainer.visible = !visible
	$CenterContainer/SettingsPanel.visible = visible

func _on_back_settings_pressed() -> void:
	_show_settings(false)

func _on_volume_changed(value: float) -> void:
	master_volume = int(value)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), master_volume == 0)
	if master_volume > 0:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume / 100.0))

func _on_easy_pressed() -> void:
	selected_difficulty = "Easy"
	_highlight_difficulty_button()

func _on_medium_pressed() -> void:
	selected_difficulty = "Medium"
	_highlight_difficulty_button()

func _on_hard_pressed() -> void:
	selected_difficulty = "Hard"
	_highlight_difficulty_button()

func _highlight_difficulty_button() -> void:
	var easy = $CenterContainer/SettingsPanel/SettingsVBox/DifficultyHBox/EasyButton
	var medium = $CenterContainer/SettingsPanel/SettingsVBox/DifficultyHBox/MediumButton
	var hard = $CenterContainer/SettingsPanel/SettingsVBox/DifficultyHBox/HardButton

	easy.modulate = Color.WHITE
	medium.modulate = Color.WHITE
	hard.modulate = Color.WHITE

	match selected_difficulty:
		"Easy":
			easy.modulate = Color.YELLOW
		"Medium":
			medium.modulate = Color.YELLOW
		"Hard":
			hard.modulate = Color.YELLOW
