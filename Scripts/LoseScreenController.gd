extends CanvasLayer

func _ready():
	var battle_manager = get_tree().root.get_node("GameBoard/BattleManager")
	var starting_health = 30
	var damage_taken = starting_health - battle_manager.player_health

	$TurnsLabel.text = "[center]Turns survived: %d[/center]" % battle_manager.turn_count
	$DamageLabel.text = "[center]You took %d damage[/center]" % damage_taken

func _on_menu_button_pressed():
	MenuManager.go_to_main_menu()
