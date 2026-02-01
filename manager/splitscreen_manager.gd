extends Node

const BASE_PLAYER = preload("res://scenes/player.tscn")
const DUMMY_VIEWPORT_IMAGE = null

@onready
var GRID_CONTAINER = $GridContainer

#For now assuming 2 players only
var player_count = 2

func _init() -> void:
	start_splitscreen.connect(_on_start_splitscreen)
	pass

signal start_splitscreen

func _ready() -> void:
	start_splitscreen.emit()

func _on_start_splitscreen() -> void:
	for i in player_count:
		setup_viewport()
	
	if(player_count % 2 != 0): #we only ever need one dummy viewport
		dummy_viewport()
		
#	for i in subviewports:
#		subviewports[i].size = subviewports[i].get_parent().size()

	pass # Replace with function body.


func dummy_viewport():
	pass

var subviewports : Array[SubViewport] 

func setup_viewport():	
	var subviewportcontianer = SubViewportContainer.new()
	var subviewport = SubViewport.new()
	var player : Player = GameManger.spawn_player(Vector3.ZERO, subviewport)
	var player_number = Global.get_player_number(player)
	subviewports.append(subviewport)
	
	subviewportcontianer.name = "Player " + str(player_number)
	subviewportcontianer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subviewportcontianer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	subviewportcontianer.add_child(subviewport)
	GRID_CONTAINER.add_child(subviewportcontianer)
	
	subviewport.size = subviewportcontianer.size
	
	var team = player_number % 2 * 2 - 1
	player.position.y = 21. * team
	pass
