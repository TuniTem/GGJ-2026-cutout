extends Node

const BASE_PLAYER = preload("uid://4mrowe64i7fu")
const CROSSHAIR = preload("uid://dvmggulbuak6s")
const WINSCREEN = preload("uid://crekgrf0q0tww")

var spawnpoints : Array[Vector3]

var scoreboard : Array[int]

@export_category("Add Point")
@export var add_point : bool :
	set(value):
		Signals.player_died.emit(Global.Team.Light)

func _init():
	Signals.player_died.connect(_on_player_died)
	Signals.game_start.connect(_on_game_start)
	scoreboard = [0, 0]
	pass

func _on_game_start():
	#Do Audio Shit
	MusicController.prep_group("mask_out")
	var c = func ():
		var last_av_sign = 0;
		while(true): #yikes
			var av_sign = 0
			for player in Global.players:
				av_sign += sign(player.position.y)
			if last_av_sign != av_sign:
				print("av_sign " + str(av_sign) + " " + str(last_av_sign))
				if(av_sign) == 0:
					MusicController.switch_song("mask_out_" + "dark" if -last_av_sign > 0 else "light", 1)
				if av_sign > 1:
					MusicController.switch_song("mask_out_light", 1.)
					pass
				if av_sign < 1:
					MusicController.switch_song("mask_out_dark", 1.)
					pass
			last_av_sign = av_sign
			await get_tree().process_frame
	c.call()
	pass

func _on_player_died(team : Global.Team):
	scoreboard[team - 1]+=1
	Global.set_score(scoreboard[0], scoreboard[1])
	print("new score is " + str(scoreboard[0]) + " vs " + str(scoreboard[1]))
	check_if_win()
	pass

func check_if_win():
	for i in len(scoreboard):
		if scoreboard[i] > Global.max_score:
			Global.winner = Global.Team.None + i 
			Signals.game_win.emit()
			pass
	pass

var last_team = 0
func spawn_player(spawnpoint : Vector3, parent : Node) -> Player:
	var player = BASE_PLAYER.instantiate() as Player
	player.team_one = !last_team
	last_team = player.team_one
	parent.add_child(player)
	return player
