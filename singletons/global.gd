extends Node

enum ProjectileType {
	HIGH_VELOCITY,
	LOW_VELOCITY
}

var mouse_captured : bool = true
var projectile_parent : Node3D

var players : Array[CharacterBody3D] = []
var avalible_controllers : Array[int] = []

var player_count = 2
var use_subwindows = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	update_controllers()
	print(avalible_controllers)

func update_controllers(): 
	avalible_controllers = Input.get_connected_joypads()
	print("controller update")

func  _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_mouse_control"):
		mouse_captured = !mouse_captured
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if mouse_captured else Input.MOUSE_MODE_VISIBLE

func get_player_number(player : CharacterBody3D):
	return players.find(player)

func request_controller_id(player : CharacterBody3D):
	var player_num : int = get_player_number(player)
	if avalible_controllers.size() > player_num:
		return avalible_controllers[player_num]
	else:
		return -1
