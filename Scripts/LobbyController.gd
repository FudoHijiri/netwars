extends Node2D

func _on_join_1_pressed():
	MenuManager.start_game("online", "medium")

func _on_join_2_pressed():
	MenuManager.start_game("online", "easy")

func _on_join_3_pressed():
	MenuManager.start_game("online", "hard")

func _on_refresh_pressed():
	pass

func _on_back_pressed():
	MenuManager.load_menu("res://Scenes/Menus/OnlineMenu.tscn")
