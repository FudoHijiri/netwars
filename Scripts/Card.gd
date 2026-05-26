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

func _ready() -> void:
	get_parent().connect_card_signals(self )
	position = Vector2(140, 955)

func _process(delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self )

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self )
