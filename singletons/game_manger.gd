extends Node

const BASE_PLAYER = preload("uid://4mrowe64i7fu")
var spawnpoints : Array[Vector3]

func spawn_player(spawnpoint : Vector3, parent : Node) -> Player:
	var player = BASE_PLAYER.instantiate() as Player
	parent.add_child(player)
	return player
