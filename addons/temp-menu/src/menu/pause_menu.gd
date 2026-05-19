class_name PauseMenu
extends Control
## Base menu scene that links to a game scene, an options menu, and credits.

signal sub_menu_opened
signal sub_menu_closed
signal game_paused
signal game_cont
signal return_menu

## Defines the path to the game scene. Hides the play button if empty.
## Will attempt to read from AppConfig if left empty.
@export_file("*.tscn") var main_menu_scene_path : String
## The scene to open when a player clicks the 'Options' button.
@export var options_packed_scene : PackedScene
@export var confirm_exit : bool = true
@export_group("Extra Settings")
### If true, signals that gameplay is paused. The pause menu should be visible
#@export var signal_game_paused : bool = false
### If true, signals that gameplay is unpaused. The pause menu should no longer be visible, and the game can be played
#@export var signal_game_cont : bool = false

var sub_menu : Control

@onready var menu_container = %MenuContainer
@onready var menu_buttons_box_container = %MenuButtonsBoxContainer
@onready var continue_button = %ContinueButton
@onready var options_button = %OptionsButton
@onready var exit_button = %ExitButton
@onready var exit_confirmation = %ExitConfirmation

func _on_ready():
	hide()
	
func get_main_menu_scene_path() -> String:
	return main_menu_scene_path

func pause_game_toggle() -> void:
	# Set var equal to what the new pause state will be
	print("Toggling pause")
	print(get_tree().paused)
	var is_paused = get_tree().paused
	if(!is_paused):
		show()
		get_tree().paused = true
	else:
		hide()
		get_tree().paused = false
	print(get_tree().paused)

func try_exit_game() -> void:
	if confirm_exit and (not exit_confirmation.visible):
		exit_confirmation.show()
	else:
		exit_game()

func exit_game() -> void:
	var scene: PackedScene = load(main_menu_scene_path) as PackedScene;
	if scene:
		get_tree().change_scene_to_packed(scene);
		#return_menu.emit()
	else:
		get_tree().change_scene_to_packed(scene);
		pass

func _open_sub_menu(menu : PackedScene) -> Node:
	sub_menu = menu.instantiate()
	add_child(sub_menu)
	menu_container.hide()
	sub_menu.hidden.connect(_close_sub_menu, CONNECT_ONE_SHOT)
	sub_menu.tree_exiting.connect(_close_sub_menu, CONNECT_ONE_SHOT)
	sub_menu_opened.emit()
	return sub_menu

func _close_sub_menu() -> void:
	if sub_menu == null:
		return
	sub_menu.queue_free()
	sub_menu = null
	menu_container.show()
	sub_menu_closed.emit()

func _event_is_mouse_button_released(event : InputEvent) -> bool:
	return event is InputEventMouseButton and not event.is_pressed()

func _input(event : InputEvent) -> void:
		if event.is_action_released("ui_cancel"):
		if sub_menu:
			_close_sub_menu()
		else:
			try_exit_game()
	if event.is_action_released("ui_accept") and get_viewport().gui_get_focus_owner() == null:
		menu_buttons_box_container.focus_first()
	if Input.is_action_just_pressed("pause_menu"):
		print("Pause via button")
		pause_game_toggle()

func _hide_exit_for_web() -> void:
	if OS.has_feature("web"):
		exit_button.hide()

func _hide_options_if_unset() -> void:
	if options_packed_scene == null:
		options_button.hide()

func _ready() -> void:
	_hide_exit_for_web()
	_hide_options_if_unset()

func _on_continue_button_pressed():
	pause_game_toggle()

func _on_options_button_pressed() -> void:
	_open_sub_menu(options_packed_scene)

func _on_exit_game_button_pressed():
	try_exit_game()

func _on_exit_confirmation_confirmed():
	exit_game()
