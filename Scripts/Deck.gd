extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const CARD_DRAW_SPEED = 0.14159
const STARTING_HAND_SIZE = 5
const CSV_PATH = "res://cards.csv"

var player_deck = []
var all_cards = {}
var drawn_card_this_turn = false

func _ready() -> void:
	_load_cards_from_csv()

	var void_cards = all_cards.values().filter(func(c): return c["faction"] == "VOID")
	for card in void_cards:
		player_deck.append(card["id"])

	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())

	for i in range(STARTING_HAND_SIZE):
		draw_card()
		drawn_card_this_turn = false
	drawn_card_this_turn = true

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

func draw_card():
	if drawn_card_this_turn or player_deck.size() == 0:
		return

	drawn_card_this_turn = true
	var card_id = player_deck[0]
	player_deck.erase(card_id)

	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false

	$RichTextLabel.text = str(player_deck.size())

	if not all_cards.has(card_id):
		return

	var card_data = all_cards[card_id]
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()

	new_card.card_id = card_id
	new_card.card_name = card_data["name"]
	new_card.card_type = card_data["type"]
	new_card.energy_cost = card_data["energy"]
	new_card.attack = card_data["atk"]
	new_card.health = card_data["hp"]
	new_card.effect = card_data["effect"]
	new_card.tooltip = card_data["tooltip"]
	new_card.faction = card_data["faction"]

	var card_image_path = str("res://Assets/" + card_data["name"] + "Card.png")
	if ResourceLoader.exists(card_image_path):
		new_card.get_node("CardImage").texture = load(card_image_path)

	new_card.get_node("Energy").text = str(card_data["energy"])

	if card_data["type"] == "AGENT":
		new_card.get_node("Attack").text = str(card_data["atk"])
		new_card.get_node("Health").text = str(card_data["hp"])
	else:
		new_card.get_node("Attack").visible = false
		new_card.get_node("Health").visible = false

	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip")

func reset_draw():
	drawn_card_this_turn = false
