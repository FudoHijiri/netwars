extends Node2D

func _on_matchmaking_button_pressed():
	MenuManager.load_menu("res://Scenes/Menus/MatchmakingQueue.tscn")

func _on_host_button_pressed():
	MenuManager.load_menu("res://Scenes/Menus/HostGame.tscn")

func _on_lobby_button_pressed():
	MenuManager.load_menu("res://Scenes/Menus/Lobby.tscn")

func _on_back_button_pressed():
	MenuManager.go_to_play_selection()
