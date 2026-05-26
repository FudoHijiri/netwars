extends Node

var all_cards: Array = []

func _ready():
	_load_csv()

func _load_csv():
	var file = FileAccess.open("res://cards.csv", FileAccess.READ)
	if file == null:
		push_error("Failed to open cards.csv")
		return

	var headers = file.get_csv_line()
	while not file.eof_reached():
		var row = file.get_csv_line()
		if row.size() < 9 or row[0] == "":
			continue

		all_cards.append({
			"id": row[0],
			"name": row[1],
			"faction": row[2],
			"type": row[3],
			"energy": int(row[4]),
			"atk": int(row[5]),
			"hp": int(row[6]),
			"effect": row[7],
			"tooltip": row[8]
		})

func get_by_id(card_id: String) -> Dictionary:
	for card in all_cards:
		if card["id"] == card_id:
			return card
	return {}

func get_by_name(card_name: String) -> Dictionary:
	for card in all_cards:
		if card["name"] == card_name:
			return card
	return {}

func get_faction(faction: String) -> Array:
	return all_cards.filter(func(c): return c.faction == faction)

func get_type(card_type: String) -> Array:
	return all_cards.filter(func(c): return c.type == card_type)

func get_all() -> Array:
	return all_cards.duplicate()
