extends Node2D

var card_type
var first_position
var attack
var health
var card_slot_card_is_in = null
var card_id = ""
var card_name = ""
var energy_cost = 0
var effect = ""
var tooltip = ""
var faction = ""
var summoning_sickness = false
var description = ""

func _ready() -> void:
	position = Vector2(1600, 125)
	_load_card_template()
	_display_card_info()

func _load_card_template() -> void:
	var template_path = _get_template_path()
	if ResourceLoader.exists(template_path):
		$CardImage.texture = load(template_path)
	else:
		push_error("Card template not found: " + template_path)

	_load_card_back()

func _load_card_back() -> void:
	var back_path = _get_back_card_path()
	if ResourceLoader.exists(back_path):
		$CardBackImage.texture = load(back_path)
	else:
		push_error("Back card template not found: " + back_path)

func _get_template_path() -> String:
	var faction_name = faction.capitalize()
	var type_name = card_type.capitalize()
	return "res://Assets/%s %s Card.png" % [faction_name, type_name]

func _get_back_card_path() -> String:
	var faction_name = faction.capitalize()
	return "res://Assets/%s Back Card.png" % faction_name

func _display_card_info() -> void:
	if has_node("Name"):
		$Name.add_theme_font_size_override("normal_font_size", 8)
		$Name.text = card_name
	if has_node("Description"):
		$Description.add_theme_font_size_override("normal_font_size", 6)
		$Description.text = description
