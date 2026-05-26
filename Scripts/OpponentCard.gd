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

func _ready() -> void:
	position = Vector2(1600, 125)
