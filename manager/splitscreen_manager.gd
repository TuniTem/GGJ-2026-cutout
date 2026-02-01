extends Node

const BASE_PLAYER = preload("res://scenes/player.tscn")
const DUMMY_VIEWPORT_IMAGE = null

@onready
var GRID_CONTAINER = $GridContainer

#For now assuming 2 players only
var player_count = 3

func _init() -> void:
	start_splitscreen.connect(_on_start_splitscreen)
	pass

signal start_splitscreen

func _on_start_splitscreen() -> void:
	for i in player_count:
		setup_viewport(i)
	
	if(player_count % 2 != 0): #we only ever need one dummy viewport
		dummy_viewport()
	pass # Replace with function body.


func dummy_viewport():
	pass

func setup_viewport(player_number : int):
	var subviewportcontianer = SubViewportContainer.new()
	var subviewport = SubViewport.new()
	subviewportcontianer.name = "Player " + str(player_number)
	subviewportcontianer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subviewportcontianer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	subviewportcontianer.add_child(subviewport)
	
	subviewport.size = subviewportcontianer.size
	subviewport.add_child(Global.players.get(player_number))
	
	GRID_CONTAINER.add_child(subviewportcontianer)
	pass
