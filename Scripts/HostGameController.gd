extends Node2D

var selected_difficulty: String = "medium"

func _ready():
	_generate_invite_code()

func _generate_invite_code():
	const CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var code = ""
	for i in range(6):
		code += CHARS[randi() % CHARS.length()]
	$InviteCodeDisplay.text = code

func _on_easy_button_pressed():
	selected_difficulty = "easy"

func _on_medium_button_pressed():
	selected_difficulty = "medium"

func _on_hard_button_pressed():
	selected_difficulty = "hard"

func _on_start_button_pressed():
	MenuManager.start_game("online", selected_difficulty)

func _on_back_button_pressed():
	MenuManager.load_menu("res://Scenes/Menus/OnlineMenu.tscn")
