extends Node

@export var map_mesh : CSGShape3D

func _ready() -> void:
	Signals.create_floor_hole.connect(_on_create_floor_hole)
	Signals.create_wall_hole.connect(_on_create_wall_hole)
	Signals.create_vertical_pillar.connect(_on_create_vertical_pillar)
	pass

var player_holes : Dictionary[int, Array]
const MAX_HOLES_PER_PLAYER = 10

func create_pillar(operation : CSGShape3D.Operation, size : Vector3, player_number : int, position : Vector3, direction : Vector3) -> void:
	print("Creating Pillar")
	if(not player_holes.has(player_number)):
		player_holes[player_number] = []
		pass
	
	if(player_holes[player_number].size() >= MAX_HOLES_PER_PLAYER):
		var tween = create_tween()
		var player_hole = player_holes[player_number].pop_front()
		tween.tween_property(player_hole, "size", Vector3.ZERO, 1.)
		tween.tween_callback(player_hole.queue_free)

	var pillar = CSGBox3D.new()
	map_mesh.add_child(pillar)
	pillar.position = position
	#pillar.position.y = 0.
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(pillar, "size:y", size.y, 1.5)
	tween.tween_property(pillar, "size:x", size.x, .25)
	tween.tween_property(pillar, "size:z", size.z, .25)
	pillar.operation = operation
	player_holes[player_number].append(pillar)
	pass

func _on_create_floor_hole(player_number : int, position : Vector3, direction : Vector3) -> void:
	create_pillar(CSGShape3D.OPERATION_SUBTRACTION, Vector3(8, 999, 8), player_number, position, direction)
	pass

func _on_create_vertical_pillar(player_number : int, position : Vector3, direction : Vector3) -> void:
	create_pillar(CSGShape3D.OPERATION_UNION, Vector3(5, 25, 5), player_number, position, direction)
	pass

func _on_create_wall_hole(player_number : int, position : Vector3, direction : Vector3) -> void:
	pass
	
