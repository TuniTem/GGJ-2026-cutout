extends Node

const BASE_PLAYER = preload("uid://4mrowe64i7fu")
const GHOST_PLAYER = preload("uid://bdynjyamj1bak")

enum ProjectileType {
	HIGH_VELOCITY,
	LOW_VELOCITY
}

#signal start_splitscreen
#signal game_start
#signal game_win
#signal player_died(team : Global.Team)


var projectile_parent : Node3D

var ghost_players : Array[CharacterBody3D] = []

var player : Player

var player_holder : Node3D

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
	player.game_ui.get_node("Luciane").text = str(team1) + "/10"
	player.game_ui.get_node("Eclipso").text = str(team2) + "/10"

func _ready() -> void:
	game_start()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	update_controllers()
	print(avalible_controllers)

func update_controllers(): 
	avalible_controllers = Input.get_connected_joypads()
	print("controller update")

#func get_player_number(player : CharacterBody3D):
	#return players.find(player)

#func request_controller_id(player : CharacterBody3D):
	#var player_num : int = get_player_number(player)
	#if avalible_controllers.size() > player_num:
		#return avalible_controllers[player_num]
	#else:
		#return -1
#
#var last_team = 0
#func spawn_player(spawnpoint : Vector3, parent : Node) -> Player:
	#var player = BASE_PLAYER.instantiate() as Player
	#player.team_one = !last_team
	#last_team = player.team_one
	#parent.add_child(player)
	#return player

func create_ghost_player(id : int):
	var inst = GHOST_PLAYER.instantiate()
	inst.steam_id = id
	player_holder.add_child(inst)

func get_ghost_player(id : int):
	print(ghost_players)
	for ghost_player : GhostPlayer in ghost_players:
		print("FINDING ", id, " and ", ghost_player.steam_id)
		if ghost_player.steam_id == id:
			return ghost_player
	
	return false

func remove_ghost_player(id : int):
	for ghost_player : GhostPlayer in ghost_players:
		if ghost_player.steam_id == id:
			ghost_players.erase(ghost_player)
			break
	

func game_start():
	MusicController.prep_group("mask_out")
	
