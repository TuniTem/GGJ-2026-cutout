extends Node

enum ProjectileType {
	HIGH_VELOCITY,
	LOW_VELOCITY
}

signal start_splitscreen
signal game_start
signal game_win
signal player_died(team : Global.Team)

var projectile_parent : Node3D

var players : Array[CharacterBody3D] = []
var avalible_controllers : Array[int] = []

var map_mesh : CSGMesh3D

#Multiplayer Settings
var player_count = 2
var use_subwindows = true
var max_score : int = 10

enum Team {None, Light, Dark}
var winner : Team = Team.None

func set_score(team1 : int, team2 : int):
	print("Setting score to " + str(team1) + " " + str(team2))
	for player : Player in players:
		player.game_ui.get_node("Luciane").text = str(team1) + "/10"
		player.game_ui.get_node("Eclipso").text = str(team2) + "/10"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	update_controllers()
	print(avalible_controllers)

func update_controllers(): 
	avalible_controllers = Input.get_connected_joypads()
	print("controller update")

func get_player_number(player : CharacterBody3D):
	return players.find(player)

func request_controller_id(player : CharacterBody3D):
	var player_num : int = get_player_number(player)
	if avalible_controllers.size() > player_num:
		return avalible_controllers[player_num]
	else:
		return -1
