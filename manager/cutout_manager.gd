extends Node

@export var map_mesh : CSGShape3D
var pillar 

func _ready() -> void:
	Signals.create_floor_hole.connect(_on_create_floor_hole)
	Signals.create_wall_hole.connect(_on_create_wall_hole)
	Signals.create_vertical_pillar.connect(_on_create_vertical_pillar)
	pass

var player_holes : Dictionary[int, Array]
const MAX_HOLES_PER_PLAYER = 1

func create_pillar(operation : CSGShape3D.Operation, player_number : int, position : Vector3) -> void:
	print("Creating Pillar")
	if(not player_holes.has(player_number)):
		player_holes[player_number] = []
		pass
	
	if(player_holes[player_number].size() > MAX_HOLES_PER_PLAYER):
		player_holes[player_number].pop_front().queue_free()

	var pillar = CSGBox3D.new()
	map_mesh.add_child(pillar)
	pillar.position = position
	pillar.position.y = 0.
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(pillar, "size:y", 25, 1.)
	tween.tween_property(pillar, "size:x", 2.5, .5)
	tween.tween_property(pillar, "size:z", 2.5, .5)
	pillar.operation = operation
	player_holes[player_number].append(pillar)
	pass

func _on_create_floor_hole(player_number : int, position : Vector3) -> void:
	create_pillar(CSGShape3D.OPERATION_SUBTRACTION, player_number, position)
	pass

func _on_create_vertical_pillar(player_number : int, position : Vector3) -> void:
	create_pillar(CSGShape3D.OPERATION_UNION, player_number, position)
	pass

func _on_create_wall_hole(player_number : int, position : Vector3) -> void:
	pass
	
