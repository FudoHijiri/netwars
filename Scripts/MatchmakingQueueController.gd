extends Node2D

func _ready():
	$SearchTimer.start()
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property($Spinner, "rotation", TAU, 1.0)

func _on_search_timer_timeout():
	MenuManager.start_game("online", "medium")

func _on_cancel_button_pressed():
	MenuManager.load_menu("res://Scenes/Menus/OnlineMenu.tscn")
