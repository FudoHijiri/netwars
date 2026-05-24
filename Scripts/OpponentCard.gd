extends Node2D

var card_type
var first_position
var attack
var health
var card_slot_card_is_in = null

func _ready() -> void:
	position = Vector2(1600, 125)
