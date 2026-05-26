extends Node2D

signal hovered
signal hovered_off

var first_position
var card_slot_card_is_in = null
var card_type
var health
var attack
var defeated = false
var card_id = ""
var card_name = ""
var energy_cost = 0
var effect = ""
var tooltip = ""
var faction = ""
var summoning_sickness = false
var description = ""

func _ready() -> void:
	get_parent().connect_card_signals(self )
	position = Vector2(140, 955)
	_load_card_template()
	_display_card_info()

func _process(delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self )

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self )

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
		$Name.text = card_name
	if has_node("Description"):
		$Description.text = description
