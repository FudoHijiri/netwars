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

	var sentinel_cards = all_cards.values().filter(func(c): return c["faction"] == "SENTINEL")
	for card in sentinel_cards:
		opponent_deck.append(card["id"])

	opponent_deck.shuffle()
	$RichTextLabel.text = str(opponent_deck.size())
	for i in range(STARTING_HAND_SIZE):
		draw_card()

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
	var card_image_path = str("res://Assets/" + card_data["name"] + "Card.png")
	if ResourceLoader.exists(card_image_path):
		new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.attack = card_data["atk"]
	new_card.get_node("Attack").text = str(new_card.attack)
	new_card.health = card_data["hp"]
	new_card.get_node("Health").text = str(new_card.health)
	new_card.get_node("Energy").text = str(card_data["energy"])
	new_card.card_type = card_data["type"]

	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../OpponentHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
