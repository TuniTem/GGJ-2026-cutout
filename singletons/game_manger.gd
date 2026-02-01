extends Node

const PLAYER = preload("res://scenes/player.tscn")
var spawnpoints : Array[Vector3]

func spawn_player(spawnpoint : Vector3, parent : Node) -> Player:
	var player = PLAYER.instantiate() as Player
	parent.add_child(player)
	return player
