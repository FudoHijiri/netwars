extends Node2D

func _on_easy_button_pressed():
	MenuManager.start_game("offline", "easy")

func _on_medium_button_pressed():
	MenuManager.start_game("offline", "medium")

func _on_hard_button_pressed():
	MenuManager.start_game("offline", "hard")

func _on_back_button_pressed():
	MenuManager.go_to_play_selection()
