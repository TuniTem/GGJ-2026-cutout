class_name ModelHelper
extends Node3D


@export var team_body_textures : Array[Texture2D]
@export var team_nametag_textures : Array[Texture2D]
@export var body : MeshInstance3D
@export var name_tag : MeshInstance3D

func set_team_colors(team : Global.Team):
	var body_material = body.mesh.surface_get_material(0) as StandardMaterial3D
	var name_tag_material = name_tag.mesh.surface_get_material(0) as StandardMaterial3D
	body.albedo_texture = team_body_textures[(team - 1)]
	name_tag.albedo_texture = team_nametag_textures[(team - 1)]
	pass
