extends Area3D
const VERTICAL_PILLAR = preload("uid://dxggktif1n26j")
const FLOOR_HOLE = preload("uid://cncqgmwykog27")


@export var model: Node3D
@export var ray_cast: RayCast3D
var team_one : bool = false


var PROJECTILE_STATS :  Dictionary = {
	Global.ProjectileType.HIGH_VELOCITY : {
		"speed" : 150.0,
		"gravity" : 0.0,
		"offset_correction_time": 0.1
	},
	Global.ProjectileType.LOW_VELOCITY : {
		"speed" : 40.0,
		"gravity" : 13.0,
		"offset_correction_time": 0.3
	}
}


var type : Global.ProjectileType
var direction : Vector3

var model_start_pos : Vector3
var pillared : bool = false

var init_vel : Vector3
var vel : Vector3 = Vector3.ZERO
var moving : bool = true
var stick_position : Vector3
var stick_normal : Vector3
var stick_is_floor : bool = false
var player_number : int = -1
var gravity_switched : bool = false
var inactive : int = 2
var player : Player

func gravity_mult() -> float:
	return -1.0 if gravity_switched else 1.0

func _ready() -> void:
	player = Global.player
	match type:
		Global.ProjectileType.HIGH_VELOCITY:
			SFX.play("shoot_high")
		
		Global.ProjectileType.LOW_VELOCITY:
			SFX.play("shoot_low")
	model.global_position = model_start_pos
	var tween : Tween = create_tween()
	tween.tween_property(model, "position", Vector3.ZERO, PROJECTILE_STATS[type]["offset_correction_time"]).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	vel = direction.normalized() * PROJECTILE_STATS[type]["speed"]
	if type == Global.ProjectileType.LOW_VELOCITY: 
		vel += init_vel

func _physics_process(delta: float) -> void:
	inactive -= 1
	if moving:
		vel.y -= PROJECTILE_STATS[type]["gravity"] * delta * gravity_mult()
		position += vel * delta
		ray_cast.target_position = vel * delta
		if stick_position:
			position = stick_position
			model.position = Vector3.ZERO
			moving = false
		
		if ray_cast.is_colliding() and not (ray_cast.get_collider() is Player and ray_cast.get_collider().team_one == team_one):
			stick_position = ray_cast.get_collision_point()
			stick_is_floor = ray_cast.get_collider().is_in_group("floor")
			if ray_cast.get_collider() is Player: kill_player(ray_cast.get_collider())
			if type == Global.ProjectileType.HIGH_VELOCITY:
				await Util.wait(0.1)
				queue_free()
	
	if position.y < 0 and not gravity_switched:
		gravity_switched = true
	
	if position.y > 0 and gravity_switched:
		gravity_switched = false
		

func kill_player(plr : Player):
	#Global.player_died.emit(Global.Team.Light if team_one else Global.Team.Dark)
	plr.kill()


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		if body.team_one == team_one: 
			return 
	if ray_cast.is_colliding():
		stick_position = ray_cast.get_collision_point()
		stick_normal = ray_cast.get_collision_normal()
		stick_is_floor = ray_cast.get_collider().is_in_group("floor")
		if ray_cast.get_collider() is Player: kill_player(ray_cast.get_collider())
		
	
	else: 
		stick_position = position
		stick_is_floor = body.is_in_group("floor")
		if body is Player: kill_player(body)
	
	moving = false


var max_dist : float = 20.0;
#var falloff : float = 2.;
@export var falloff : Curve;

# for all of these keep in min that "up/down" is relitive
func explode(): # forces all players within a radius away
	var dir = global_position - Global.player.global_position;
	var force_mag = falloff.sample(clamp(dir.length()-max_dist, 0.0, 1.0))
	print("inpt ", clamp(dir.length()-max_dist, 0.0, 1.0))
	Global.player.add_force(-dir.normalized() * force_mag * 60.0)
	queue_free()


#func create_wall_hole(): # make an inteirior raycast inside the in direction of [vel], create a boolian csgcube that goes from the projectriles pos to the raycast end, if no raycast run explode()  
	#Signals.create_wall_hole.emit(player_number, position, stick_normal)
	#pass

func create_vertical_pillar():
	var inst = VERTICAL_PILLAR.instantiate()
	inst.flipped = player.gravity_switched
	inst.global_position = global_position
	player.structure_buffer.push(inst)
	Global.map_mesh.add_child(inst)
	queue_free()
	

func create_floor_hole():
	var inst = FLOOR_HOLE.instantiate()
	inst.flipped = player.gravity_switched
	inst.global_position = global_position
	inst.point_towards = global_position + vel
	#inst.point_towards = global_position * 2 - player.global_position 
	player.structure_buffer.push(inst)
	Global.map_mesh.add_child(inst)
	queue_free()
