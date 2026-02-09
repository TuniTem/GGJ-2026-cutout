extends CharacterBody3D
class_name GhostPlayer

var internal_velocity : Vector3 = Vector3.ZERO
var steam_id : int = -2


func _init() -> void:
	Global.ghost_players.append(self)

func add_force(vector : Vector3):
	pass

func _physics_process(delta: float) -> void:
	Debug.draw_vector3(global_position + velocity, global_position, self, "vel")
	#global_position = Net.get_interpolated_value("position", self, global_position)
	#internal_velocity = Net.get_interpolated_value("velocity", self, internal_velocity)
	#print(global_position)
