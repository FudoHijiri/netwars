extends Node2D

var master_volume = 100
var default_difficulty = "medium"

func _ready() -> void:
	$VolumeSlider.value = master_volume
	$VolumeSlider.value_changed.connect(_on_volume_changed)
	$EasyButton.pressed.connect(_on_easy_difficulty)
	$MediumButton.pressed.connect(_on_medium_difficulty)
	$HardButton.pressed.connect(_on_hard_difficulty)
	$BackButton.pressed.connect(_on_back_button_pressed)
	_highlight_difficulty_button()

func _on_volume_changed():
	master_volume = int($VolumeSlider.value)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), master_volume == 0)

func _on_easy_difficulty():
	default_difficulty = "easy"
	_highlight_difficulty_button()

func _on_medium_difficulty():
	default_difficulty = "medium"
	_highlight_difficulty_button()

func _on_hard_difficulty():
	default_difficulty = "hard"
	_highlight_difficulty_button()

func _highlight_difficulty_button() -> void:
	var buttons = [$EasyButton, $MediumButton, $HardButton]
	var difficulties = ["easy", "medium", "hard"]
	for i in range(buttons.size()):
		if difficulties[i] == default_difficulty:
			buttons[i].add_theme_color_override("font_color", Color.YELLOW)
		else:
			buttons[i].remove_theme_color_override("font_color")

func _on_back_button_pressed():
	MenuManager.go_to_title_menu()
