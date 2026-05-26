extends Node2D

func _ready():
	var game_mode = MenuManager.game_mode
	var difficulty = MenuManager.game_difficulty

	if game_mode == "offline":
		_setup_offline_game(difficulty)
	elif game_mode == "online":
		_setup_online_game(difficulty)

	$BattleManager.game_ended.connect(_on_game_ended)

func _setup_offline_game(difficulty: String):
	$OpponentDeck.set_difficulty(difficulty)
	$BattleManager.set_difficulty(difficulty)

func _setup_online_game(difficulty: String):
	$OpponentDeck.set_difficulty(difficulty)
	$BattleManager.set_difficulty(difficulty)

func _on_game_ended(winner: String):
	await get_tree().process_frame
	if winner == "player":
		var win_screen = load("res://Scenes/WinScreen.tscn").instantiate()
		get_tree().root.add_child(win_screen)
	else:
		var lose_screen = load("res://Scenes/LoseScreen.tscn").instantiate()
		get_tree().root.add_child(lose_screen)

func _on_back_to_menu_pressed():
	MenuManager.go_to_main_menu()
