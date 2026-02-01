extends Area3D

@export var model: Node3D
@export var ray_cast: RayCast3D

const PROJECTILE_STATS :  Dictionary = {
	Global.ProjectileType.HIGH_VELOCITY : {
		"speed" : 50.0,
		"gravity" : 5.0,
		"offset_correction_time": 0.1
	},
	Global.ProjectileType.LOW_VELOCITY : {
		"speed" : 30.0,
		"gravity" : 13.0,
		"offset_correction_time": 0.3
	},
}


var type : Global.ProjectileType
var direction : Vector3

var model_start_pos : Vector3
var pillared : bool = false

var vel : Vector3 = Vector3.ZERO
var moving : bool = true
var stick_position : Vector3
var stick_is_floor : bool = false
var player_number : int = -1
var gravity_switched : bool = false

func gravity_mult() -> float:
	return -1.0 if gravity_switched else 1.0

func _ready() -> void:
	print("readypos ", position)
	model.global_position = model_start_pos
	var tween : Tween = create_tween()
	tween.tween_property(model, "position", Vector3.ZERO, PROJECTILE_STATS[type]["offset_correction_time"]).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	vel = direction.normalized() * PROJECTILE_STATS[type]["speed"]

func _physics_process(delta: float) -> void:
	if moving:
		print("2pos", position)
		
		vel.y -= PROJECTILE_STATS[type]["gravity"] * delta * gravity_mult()
		position += vel * delta
		ray_cast.target_position = vel * delta
		if stick_position:
			print("a")
			position = stick_position
			model.position = Vector3.ZERO
			moving = false
		
		if ray_cast.is_colliding():
			print("stick2")
			stick_position = ray_cast.get_collision_point()
			stick_is_floor = ray_cast.get_collider().is_in_group("floor")
	
	if position.y < 0 and not gravity_switched:
		gravity_switched = true
	
	if position.y > 0 and gravity_switched:
		gravity_switched = false
		


func _on_body_entered(body: Node3D) -> void:
	print("stick4")
	if ray_cast.is_colliding():
		print("stick1")
		stick_position = ray_cast.get_collision_point()
		stick_is_floor = ray_cast.get_collider().is_in_group("floor")
	
	else: 
		print("stick3")
		stick_position = position
		stick_is_floor = body.is_in_group("floor")
	
	moving = false


var max_dist : float = 1.;
#var falloff : float = 2.;
@export var falloff : Curve;

# for all of these keep in min that "up/down" is relitive
func explode(): # forces all players within a radius away
	for player : Player in Global.players:
		var dir = self.position - player.position;
		var force_mag = falloff.sample(max(0, max_dist - dir.length(), 0))
		player.add_force(dir.normalized() * force_mag)
	pass

func create_floor_hole(): # floor hole, should also force nearby players down into new floor hole
	Signals.create_floor_hole.emit(player_number, position)
	pass

func create_wall_hole(): # make an inteirior raycast inside the in direction of [vel], create a boolian csgcube that goes from the projectriles pos to the raycast end, if no raycast run explode()  
	Signals.create_wall_hole.emit(player_number, position)
	pass

func create_vertical_pillar(): # creates a solid vertical pillar, players above it get forced up
	Signals.create_vertical_pillar.emit(player_number, position)
	pass
