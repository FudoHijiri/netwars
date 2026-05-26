extends Node2D

func _on_offline_button_pressed():
	MenuManager.go_to_offline_selection()

func _on_online_button_pressed():
	MenuManager.go_to_online_selection()

func _on_back_button_pressed():
	MenuManager.go_to_main_menu()
