extends Node

enum ProjectileType {
	HIGH_VELOCITY,
	LOW_VELOCITY
}

var mouse_captured : bool = true
var projectile_parent : Node3D

var players : Array[CharacterBody3D] = []

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func  _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_mouse_control"):
		mouse_captured = !mouse_captured
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if mouse_captured else Input.MOUSE_MODE_VISIBLE

func get_player_number(player : CharacterBody3D):
	return players.find(player)
