extends Node

signal menu_changed(menu_name: String)

var current_menu_node: Node = null
var current_menu_path: String = ""
var game_mode: String = ""
var game_difficulty: String = ""

const MENU_CONTAINER_PATH = "MenuContainer"

func _ready():
	var container = Node.new()
	container.name = MENU_CONTAINER_PATH
	add_child(container)

func load_menu(menu_path: String) -> void:
	if current_menu_node:
		current_menu_node.queue_free()

	var menu_scene = load(menu_path)
	current_menu_node = menu_scene.instantiate()
	get_node(MENU_CONTAINER_PATH).add_child(current_menu_node)
	current_menu_path = menu_path

	var menu_name = menu_path.split("/")[-1].trim_suffix(".tscn")
	menu_changed.emit(menu_name)

func go_to_title_menu() -> void:
	load_menu("res://Scenes/Menus/TitleMenu.tscn")

func go_to_main_menu() -> void:
	load_menu("res://Scenes/Menus/MainMenu.tscn")

func go_to_play_selection() -> void:
	load_menu("res://Scenes/Menus/PlaySelectionMenu.tscn")

func go_to_offline_selection() -> void:
	load_menu("res://Scenes/Menus/OfflineMenu.tscn")

func go_to_online_selection() -> void:
	load_menu("res://Scenes/Menus/OnlineMenu.tscn")

func start_game(mode: String, difficulty: String = "") -> void:
	game_mode = mode
	game_difficulty = difficulty

	if current_menu_node:
		current_menu_node.queue_free()
		current_menu_node = null

	get_tree().change_scene_to_file("res://Scenes/GameBoard.tscn")

func exit_game() -> void:
	get_tree().quit()
