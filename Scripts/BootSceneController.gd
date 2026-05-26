extends Node2D

func _ready():
	$TransitionTimer.start()

func _on_transition_timer_timeout():
	MenuManager.go_to_title_menu()
