extends Node

const CARD_SMALLER_SCALE = 1
const CARD_MOVE_SPEED = 0.4
const STARTING_HEALTH = 30
const BATTLE_POS_OFFSET = 25

var battle_timer
var empty_attack_cards_slots = []
var opponent_cards_on_battlefield = []
var player_cards_on_battlefield = []
var player_cards_that_attacked_this_turn = []
var player_health
var opponent_health
var is_opponents_turn = false
var player_is_attacking = false
var difficulty: String = "medium"
var player_energy = 1
var opponent_energy = 1
var max_energy_this_turn = 1
var turn_count = 0
var game_over = false

signal game_ended(winner: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_timer = $"../BattleTimer"
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0

	empty_attack_cards_slots.append($"../CardSlots/EnemyCardSlot")
	empty_attack_cards_slots.append($"../CardSlots/EnemyCardSlot2")
	empty_attack_cards_slots.append($"../CardSlots/EnemyCardSlot3")

	player_health = STARTING_HEALTH
	$"../PlayerHealth".text = str(player_health)
	opponent_health = STARTING_HEALTH
	$"../OpponentHealth".text = str(opponent_health)

func set_difficulty(new_difficulty: String) -> void:
	difficulty = new_difficulty

func _start_new_turn() -> void:
	turn_count += 1
	max_energy_this_turn = min(turn_count + 1, 10)
	player_energy = max_energy_this_turn
	opponent_energy = max_energy_this_turn
	_update_energy_display()

func _spend_player_energy(amount: int) -> bool:
	if player_energy >= amount:
		player_energy -= amount
		_update_energy_display()
		return true
	return false

func _update_energy_display() -> void:
	if $"../PlayerEnergyLabel":
		$"../PlayerEnergyLabel".text = "Energy: %d/%d" % [player_energy, max_energy_this_turn]

func _check_game_end() -> void:
	if player_health <= 0 and not game_over:
		game_over = true
		game_ended.emit("opponent")
	elif opponent_health <= 0 and not game_over:
		game_over = true
		game_ended.emit("player")

func _on_end_turn_button_pressed() -> void:
	is_opponents_turn = true
	$"../CardManager".unselect_selected_monster()
	player_cards_that_attacked_this_turn = []
	opponent_turn()


func opponent_turn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false

	if difficulty == "easy":
		await _easy_opponent_turn()
	elif difficulty == "medium":
		await _medium_opponent_turn()
	elif difficulty == "hard":
		await _hard_opponent_turn()
	else:
		await _medium_opponent_turn()

func _easy_opponent_turn():
	if $"../OpponentDeck".opponent_deck.size() != 0:
		$"../OpponentDeck".draw_card()
		battle_timer.wait_time = 2.0
		battle_timer.start()
		await battle_timer.timeout

	if empty_attack_cards_slots.size() != 0 and randf() > 0.5:
		await _play_random_card_easy()

	if opponent_cards_on_battlefield.size() != 0:
		var enemy_cards = opponent_cards_on_battlefield.duplicate()
		for card in enemy_cards:
			if randf() > 0.3:
				if player_cards_on_battlefield.size() > 0 and randf() > 0.4:
					var target = player_cards_on_battlefield.pick_random()
					await attack(card, target, "Opponent")
				else:
					await direct_attack(card, "Opponent")
			battle_timer.wait_time = 1.5
			battle_timer.start()
			await battle_timer.timeout
	end_opponent_turn()

func _medium_opponent_turn():
	if $"../OpponentDeck".opponent_deck.size() != 0:
		$"../OpponentDeck".draw_card()
		battle_timer.start()
		await battle_timer.timeout

	if empty_attack_cards_slots.size() != 0:
		await try_play_card_with_highest_attack()

	if opponent_cards_on_battlefield.size() != 0:
		var enemy_cards_to_attack = opponent_cards_on_battlefield.duplicate()
		for card in enemy_cards_to_attack:
			if player_cards_on_battlefield.size() != 0:
				var card_to_attack = player_cards_on_battlefield.pick_random()
				await attack(card, card_to_attack, "Opponent")
			else:
				await direct_attack(card, "Opponent")
	end_opponent_turn()

func _hard_opponent_turn():
	if $"../OpponentDeck".opponent_deck.size() != 0:
		$"../OpponentDeck".draw_card()
		battle_timer.wait_time = 0.5
		battle_timer.start()
		await battle_timer.timeout

	if empty_attack_cards_slots.size() != 0:
		await _play_optimal_card_hard()

	if opponent_cards_on_battlefield.size() != 0:
		var enemy_cards = opponent_cards_on_battlefield.duplicate()
		for card in enemy_cards:
			var target = _select_optimal_target_hard()
			if target:
				await attack(card, target, "Opponent")
			else:
				await direct_attack(card, "Opponent")
	end_opponent_turn()

func _play_random_card_easy():
	var opponent_hand = $"../OpponentHand".opponent_hand
	if opponent_hand.size() == 0:
		return

	var card = opponent_hand.pick_random()
	var slot = empty_attack_cards_slots.pick_random()
	empty_attack_cards_slots.erase(slot)

	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", slot.position, CARD_MOVE_SPEED)
	card.get_node("AnimationPlayer").play("card_flip")

	$"../OpponentHand".remove_card_from_hand(card)
	card.card_slot_card_is_in = slot
	opponent_cards_on_battlefield.append(card)

	await wait(1.0)

func _play_optimal_card_hard():
	var opponent_hand = $"../OpponentHand".opponent_hand
	if opponent_hand.size() == 0:
		return

	var best_card = opponent_hand[0]
	for card in opponent_hand:
		if card.attack > best_card.attack or (card.attack == best_card.attack and card.health > best_card.health):
			best_card = card

	var slot = empty_attack_cards_slots.pick_random()
	empty_attack_cards_slots.erase(slot)

	var tween = get_tree().create_tween()
	tween.tween_property(best_card, "position", slot.position, CARD_MOVE_SPEED)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(best_card, "scale", Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE), CARD_MOVE_SPEED)
	best_card.get_node("AnimationPlayer").play("card_flip")

	$"../OpponentHand".remove_card_from_hand(best_card)
	best_card.card_slot_card_is_in = slot
	opponent_cards_on_battlefield.append(best_card)

	await wait(1.0)

func _select_optimal_target_hard():
	if player_cards_on_battlefield.size() == 0:
		return null

	var threat = player_cards_on_battlefield[0]
	for card in player_cards_on_battlefield:
		if card.attack > threat.attack:
			threat = card
	return threat


func direct_attack(attacking_card, attacker):
	var new_pos_y
	if attacker == "Opponent":
		new_pos_y = 1080
	else:
		$"../EndTurnButton".disabled = true
		$"../EndTurnButton".visible = false
		player_is_attacking = true
		new_pos_y = 0
		player_cards_that_attacked_this_turn.append(attacking_card)
	
	var new_pos = Vector2(attacking_card.position.x, new_pos_y)
	
	attacking_card.z_index = 5
	
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	await wait(0.15)
	
	if attacker == "Opponent":
		player_health = max(0, player_health - attacking_card.attack)
		$"../PlayerHealth".text = str(player_health)
	else:
		opponent_health = max(0, opponent_health - attacking_card.attack)
		$"../OpponentHealth".text = str(opponent_health)

	_check_game_end()
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, CARD_MOVE_SPEED)
	
	attacking_card.z_index = 0
	await wait(1.0)
	if attacker == "Player":
		player_is_attacking = false
		$"../EndTurnButton".disabled = false
		$"../EndTurnButton".visible = true
	

func attack(attacking_card, defending_card, attacker):
	if attacker == "Player":
		$"../EndTurnButton".disabled = true
		$"../EndTurnButton".visible = false
		player_is_attacking = true
		$"../CardManager".selected_monster = null
		player_cards_that_attacked_this_turn.append(attacking_card)
	
	attacking_card.z_index = 5
	
	var new_pos = Vector2(defending_card.position.x, defending_card.position.y + BATTLE_POS_OFFSET)
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	await wait(0.15)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, CARD_MOVE_SPEED)
	
	defending_card.health = max(0, defending_card.health - attacking_card.attack)
	defending_card.get_node("Health").text = str(defending_card.health)
	
	attacking_card.health = max(0, attacking_card.health - defending_card.attack)
	attacking_card.get_node("Health").text = str(attacking_card.health)
	
	await wait(1.0)
	attacking_card.z_index = 0
	
	var card_was_destroyed = false
	
	if attacking_card.health == 0:
		destroy_card(attacking_card, attacker)
		card_was_destroyed = true
	if defending_card.health == 0:
		if attacker == "Player":
			destroy_card(defending_card, "Opponent")
		else:
			destroy_card(defending_card, "Player")
		card_was_destroyed = true
	
	if card_was_destroyed:
		await wait(1.0)

	_check_game_end()

	if attacker == "Player":
		player_is_attacking = false
		$"../EndTurnButton".disabled = false
		$"../EndTurnButton".visible = true

func destroy_card(card, card_owner):
	var new_pos
	if card_owner == "Player":
		card.defeated = true
		card.get_node("Area2D/CollisionShape2D").disabled = true
		new_pos = $"../PlayerDiscard".position
		if card in player_cards_on_battlefield:
			player_cards_on_battlefield.erase(card)
			card.card_slot_card_is_in.get_node("Area2D/CollisionShape2D").disabled = false
			card.card_slot_card_is_in.card_in_slot = false # moved inside Player block
			card.card_slot_card_is_in.visible = true
			card.card_slot_card_is_in = null
	else:
		new_pos = $"../OpponentDiscard".position
		if card in opponent_cards_on_battlefield:
			opponent_cards_on_battlefield.erase(card)
	
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_pos, CARD_MOVE_SPEED)

func enemy_card_selected(defending_card):
	var attacking_card = $"../CardManager".selected_monster
	if attacking_card:
		if defending_card in opponent_cards_on_battlefield:
			if player_is_attacking == false:
				$"../CardManager".selected_monster = null
				attack(attacking_card, defending_card, "Player")


func try_play_card_with_highest_attack():
	var opponent_hand = $"../OpponentHand".opponent_hand
	if opponent_hand.size() == 0:
		end_opponent_turn()
		return
	var random_empty_attack_cards_slots = empty_attack_cards_slots.pick_random()
	empty_attack_cards_slots.erase(random_empty_attack_cards_slots)
	
	
	var card_with_highest_attack = opponent_hand[0]
	
	for card in opponent_hand:
		if card.attack > card_with_highest_attack.attack:
			card_with_highest_attack = card
	
	var tween = get_tree().create_tween()
	tween.tween_property(card_with_highest_attack, "position", random_empty_attack_cards_slots.position, CARD_MOVE_SPEED)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(card_with_highest_attack, "scale", Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE), CARD_MOVE_SPEED)
	card_with_highest_attack.get_node("AnimationPlayer").play("card_flip")
	
	$"../OpponentHand".remove_card_from_hand(card_with_highest_attack)
	card_with_highest_attack.card_slot_card_is_in = random_empty_attack_cards_slots
	#random_empty_attack_cards_slots.visible = false
	
	opponent_cards_on_battlefield.append(card_with_highest_attack)
	
	await wait(1.0)

func wait(wait_time):
	battle_timer.wait_time = wait_time
	battle_timer.start()
	await battle_timer.timeout

func end_opponent_turn():
	$"../Deck".reset_draw()
	$"../Deck".draw_card()
	$"../CardManager".reset_played_attack()
	is_opponents_turn = false
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true
	_start_new_turn()
	$"../EndTurnButton".visible = true
