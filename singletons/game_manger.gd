extends Node

const USING_KEEB : bool = true
var used_keeb : bool = false

const BASE_PLAYER = preload("uid://4mrowe64i7fu")
const CROSSHAIR = preload("uid://dvmggulbuak6s")
var spawnpoints : Array[Vector3]

var scoreboard : Array[int]

func _init():
	Signals.player_died.connect(_on_player_died)
	pass

func _on_player_died():
	check_if_win()
	pass

func check_if_win():
	for i in range(scoreboard):
		if scoreboard[i] > Global.max_score:
			Signals.game_win.emit(i) #Team 0 is light, 1 is Dark
			pass
	pass

func spawn_player(spawnpoint : Vector3, parent : Node) -> Player:
	var player = BASE_PLAYER.instantiate() as Player
	if USING_KEEB and not used_keeb:
		player.using_controller = false
		used_keeb = true
	
	
	parent.add_child(player)
	return player
