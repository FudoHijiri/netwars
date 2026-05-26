extends Node2D

const CARD_SCENE_PATH = "res://Scenes/OpponentCard.tscn"
const CARD_DRAW_SPEED = 0.14159
const STARTING_HAND_SIZE = 5
const CSV_PATH = "res://cards.csv"

var opponent_deck = []
var all_cards = {}
var difficulty: String = "medium"

func _ready() -> void:
	_load_cards_from_csv()
	_load_deck_sprite()

	var sentinel_cards = all_cards.values().filter(func(c): return c["faction"] == "SENTINEL")
	for card in sentinel_cards:
		opponent_deck.append(card["id"])

	opponent_deck.shuffle()
	$RichTextLabel.text = str(opponent_deck.size())
	for i in range(STARTING_HAND_SIZE):
		draw_card()

func _load_deck_sprite() -> void:
	if has_node("Sprite2D"):
		var back_card_path = "res://Assets/Sentinel Back Card.png"
		if ResourceLoader.exists(back_card_path):
			$Sprite2D.texture = load(back_card_path)

func _load_cards_from_csv() -> void:
	var file = FileAccess.open(CSV_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open cards.csv")
		return

	var headers = file.get_csv_line()
	while not file.eof_reached():
		var row = file.get_csv_line()
		if row.size() < 9 or row[0] == "":
			continue

		var card = {
			"id": row[0],
			"name": row[1],
			"faction": row[2],
			"type": row[3],
			"energy": int(row[4]),
			"atk": int(row[5]),
			"hp": int(row[6]),
			"effect": row[7],
			"tooltip": row[8]
		}
		all_cards[card["id"]] = card

func set_difficulty(new_difficulty: String) -> void:
	difficulty = new_difficulty

func draw_card():
	if opponent_deck.size() == 0:
		return

	var card_id = opponent_deck[0]
	opponent_deck.erase(card_id)

	if opponent_deck.size() == 0:
		$Sprite2D.visible = false
		$RichTextLabel.visible = false

	$RichTextLabel.text = str(opponent_deck.size())

	if not all_cards.has(card_id):
		return

	var card_data = all_cards[card_id]
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()

	new_card.card_id = card_id
	new_card.card_name = card_data["name"]
	new_card.card_type = card_data["type"]
	new_card.faction = card_data["faction"]
	new_card.energy_cost = card_data["energy"]
	new_card.attack = card_data["atk"]
	new_card.health = card_data["hp"]
	new_card.effect = card_data["effect"]
	new_card.tooltip = card_data["tooltip"]
	new_card.description = card_data["tooltip"]

	new_card.get_node("Energy").text = str(card_data["energy"])

	if card_data["type"] == "AGENT":
		new_card.get_node("Attack").text = str(card_data["atk"])
		new_card.get_node("Health").text = str(card_data["hp"])
	else:
		new_card.get_node("Attack").visible = false
		new_card.get_node("Health").visible = false

	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../OpponentHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
