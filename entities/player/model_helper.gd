class_name ModelHelper
extends Node3D

@export_category("Add Point")
@export var switch_team_visual : bool :
	set(value):
		set_team_colors((int(value) + 1) as Global.Team)

@export var team_body_textures = [load("uid://bm7keia12tqe0"), load("uid://dqbwxi48e8nqa")]
#@export var team_nametag_textures : Array[Texture2D]
@onready var body : MeshInstance3D = $EclipsoRig/Skeleton3D/Eclipso_Body
#@export var name_tag : MeshInstance3D

func set_team_colors(team : Global.Team):
	await body != null
	print("switching to team " + str(team))
	var body_material : StandardMaterial3D = body.get_active_material(0) as StandardMaterial3D
#	var name_tag_material = name_tag.mesh.surface_get_material(0) as StandardMaterial3D
	body_material = body_material.duplicate()
	body_material.albedo_texture = team_body_textures[(team - 1)]
	body.set_surface_override_material(0, body_material)
#	name_tag.albedo_texture = team_nametag_textures[(team - 1)]
	pass
