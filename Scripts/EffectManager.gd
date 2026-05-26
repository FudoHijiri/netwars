extends Node

var card_database

func _ready():
	card_database = preload("res://Scripts/CardDatabase.gd")

func execute_effect(card_data: Dictionary, battle_manager: Node, attacker: String) -> void:
	if card_data.is_empty() or not card_data.has("effect"):
		return

	var effect = card_data["effect"].to_lower()

	if "deal" in effect and "damage" in effect:
		_parse_direct_damage(effect, battle_manager, attacker)
	elif "draw" in effect and "card" in effect:
		_parse_draw_cards(effect, battle_manager, attacker)
	elif "summon" in effect and "token" in effect:
		_parse_summon_token(effect, battle_manager, attacker)
	elif "taunt" in effect:
		_apply_taunt(card_data, battle_manager, attacker)
	elif "cannot attack this turn" in effect:
		_apply_summoning_sickness(card_data)

func _parse_direct_damage(effect: String, battle_manager: Node, attacker: String) -> void:
	var damage = 1
	if "1" in effect:
		damage = 1
	elif "2" in effect:
		damage = 2
	elif "3" in effect:
		damage = 3
	elif "4" in effect:
		damage = 4
	elif "5" in effect:
		damage = 5

	if attacker == "Player":
		battle_manager.opponent_health = max(0, battle_manager.opponent_health - damage)
		battle_manager.get_node("../OpponentHealth").text = str(battle_manager.opponent_health)
	else:
		battle_manager.player_health = max(0, battle_manager.player_health - damage)
		battle_manager.get_node("../PlayerHealth").text = str(battle_manager.player_health)

	battle_manager._check_game_end()

func _parse_draw_cards(effect: String, battle_manager: Node, attacker: String) -> void:
	var count = 1
	if "1" in effect:
		count = 1
	elif "2" in effect:
		count = 2
	elif "3" in effect:
		count = 3

	if attacker == "Player":
		for i in range(count):
			if battle_manager.get_node("../Deck"):
				battle_manager.get_node("../Deck").draw_card()
	else:
		for i in range(count):
			if battle_manager.get_node("../OpponentDeck"):
				battle_manager.get_node("../OpponentDeck").draw_card()

func _parse_summon_token(effect: String, battle_manager: Node, attacker: String) -> void:
	var token_count = 1
	if "two" in effect or "2" in effect:
		token_count = 2
	elif "three" in effect or "3" in effect:
		token_count = 3

	var token_stats = {"attack": 1, "health": 1, "name": "Token"}

	for i in range(token_count):
		pass

func _apply_taunt(card_data: Dictionary, battle_manager: Node, attacker: String) -> void:
	card_data["has_taunt"] = true

func _apply_summoning_sickness(card_data: Dictionary) -> void:
	card_data["summoning_sickness"] = true

func has_taunt(card_data: Dictionary) -> bool:
	return card_data.get("has_taunt", false) or "taunt" in card_data.get("effect", "").to_lower()

func has_summoning_sickness(card_data: Dictionary) -> bool:
	return card_data.get("summoning_sickness", false) or "cannot attack this turn" in card_data.get("effect", "").to_lower()
