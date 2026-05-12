extends Node

const CARD_SMALLER_SCALE = 1
const CARD_MOVE_SPEED = 0.4

var battle_timer
var empty_attack_cards_slots = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_timer = $"../BattleTimer"
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	
	empty_attack_cards_slots.append($"../CardSlots/EnemyCardSlot")
	empty_attack_cards_slots.append($"../CardSlots/EnemyCardSlot2")
	empty_attack_cards_slots.append($"../CardSlots/EnemyCardSlot3")




func _on_end_turn_button_pressed() -> void:
	opponent_turn()


func opponent_turn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false
	
	if $"../OpponentDeck".opponent_deck.size() != 0:
		$"../OpponentDeck".draw_card()
		
		battle_timer.start()
		await battle_timer.timeout

	if empty_attack_cards_slots.size() == 0:
		end_opponent_turn()
		return
	
	await try_play_card_with_highest_attack()
	
	end_opponent_turn()

func try_play_card_with_highest_attack():
	var opponent_hand = $"../OpponentHand".opponent_hand
	if opponent_hand.size() == 0:
		end_opponent_turn()
		return
	var random_empty_attack_cards_slots = empty_attack_cards_slots[randi_range(0, empty_attack_cards_slots.size() - 1)]
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
	random_empty_attack_cards_slots.visible = false
	battle_timer.start()
	await battle_timer.timeout

func end_opponent_turn():
	$"../Deck".reset_draw()
	$"../CardManager".reset_played_attack()
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true
