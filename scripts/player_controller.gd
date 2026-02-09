class_name Player
extends CharacterBody3D

var ui : Control

var player_number : int = -1
var using_controller : bool = false
var device_id: int = -1
var song_leader : bool = false

const PROJECTILE = preload("uid://dgpicqgfhtwwf")
@export_category("Node")
@export var crosshair : DrawCrosshair 
@export var actual_projectile_spawn: Marker3D
@export var model_projectile_spawn: Marker3D
@export var animation_player: AnimationPlayer
@export var flip_anim: AnimationPlayer
@export var camera : Camera3D
@export var game_ui : Control

@export_category("Skin")
@export var team_body_textures = [load("uid://bm7keia12tqe0"), load("uid://dqbwxi48e8nqa")]

@export var eclipso_skeleton : Skeleton3D 
@export var lunaire_skeleton : Skeleton3D 
@export var eclipso_skin : Node3D
@export var lunaire_skin : Node3D


const SENSITIVITY = 1.0
const FOV = 100

# movement
const MAX_SPEED = 20.0
const ACCEL = 30.0
const GRAVITY = 20.0
const TERMINAL_VELOCITY = 60.0
const WEAK_DRAG = 20.0
const STRONG_DRAG = 40.0
const MEGA_DRAG = 100.0
const DEADZOME = 0.1
const Y_CLAMP = [-PI / 2.0 - 0.1, PI / 2.0 - 0.1]



const JUMP_VEL = 7.5

var dir : Vector2

const SHOOT_CHARGE_COST = 0.4
const CHARGE_SPEED_MULT = 0.01
var charge : float = 0.0

var gravity_switched : bool = false:
	set(val):
		if val != gravity_switched:
			SFX.play("swap")
			add_force(Vector3(0, 2, 0) * (2 * int(gravity_switched) - 1))
		
		rotation.y += PI
		#look_dir.reflect(=)
		gravity_switched = val
		
		
var vel2D : Vector2 = Vector2.ZERO

# alt move
const SLOWDOWN_TIME = 1.0
const MIN_SLIDE_SPEED = 10.0
const BOUNCE_TIMER = 0.1 
const MOVEMENT_CONTROL_VEL_TIME = 1.0

var movement_ctrl_timer = -1.0
var movement_ctrl_stored_speed : float

var slowdown : float = -1.0
var is_sliding = false:
	set(val):
		is_sliding = val
		animation_player.play("initiate_slide" if is_sliding else "exit_slide", 0.05)
		if is_sliding: SFX.play("slide")

var slide_speed : float = 0.0
var slide_direction : Vector2
var bounce_timer : float = -1.0
var can_slide : bool = true

# zoom
const ZOOM_AMMOUNT = 0.4
const ZOOM_SPEED = 10.0
const ZOOM_SENSITIVITY_EFFECT = 0.5
var zoom : bool = false
var team_one : bool = false

#in seconds
var SHOOTING_COOLDOWN = 0.5
var can_shoot = true

# shooting
const MAX_STRUCTURES = 3
@export_category("Aim Assist")
@export var enable_aim_assist : bool = true
@export var aim_assit_kbm : bool = true
@export var speed_based : bool = true
@export var speed_assist_max : float = 50
@export var speed_assist_curve : Curve
@export var controller_assist_curve : Curve
@export var keyboard_assist_curve : Curve
@export_range(0.0, 20.0, 0.1) var max_assist_angle_degrees : float

var projectile_mode : Global.ProjectileType = Global.ProjectileType.LOW_VELOCITY
var active_projectile : Area3D
var look_dir : Vector2
var structure_buffer : Buffer


@onready var elipso_anim: AnimationPlayer = $Ecliplso/ElipsoAnim
@onready var animaman: AnimationTree = $Ecliplso/ElipsoAnim/animaman

func _init() -> void:
	Global.players.append(self)
	player_number = Global.get_player_number(self)
	#set_collision_layer_value(player_number + 1, true)
	
	#print(collision_layer)
	device_id = Global.request_controller_id(self)
	#print(device_id)
	
	if device_id == -1:
		using_controller = false

func _ready() -> void:
	MusicController.fade("mask_out_light" if position.y > 0.0 else "mask_out_dark", 1.0, 1.0, true)
	
	scale = Vector3.ONE * 1.5
	skeleton = eclipso_skeleton
	structure_buffer = Buffer.new(MAX_STRUCTURES, Buffer.Type.NODE_METHOD)
	structure_buffer.set_method("kill")
	
	var mask = 20 - player_number
	camera.set_cull_mask_value(mask, false)
	
	for child : MeshInstance3D in eclipso_skeleton.get_children():# + lunaire_skeleton.get_children():
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(mask, true)

var skeleton : Skeleton3D

func set_team_colors(team : Global.Team):
	if team == Global.Team.Dark:
		eclipso_skin.show()
		lunaire_skin.hide()
	
	else:
		eclipso_skin.hide()
		lunaire_skin.show()



func gravity_mult() -> float:
	return -1.0 if gravity_switched else 1.0

var prev_vel : Vector3
var is_movement_ctrl_pressed : bool = false
var is_jump_pressed : bool = false
var prev_trigger : float = 0.0
const FOOTSTEP_INTERVAL = 5.0
var footstep_timer : float = FOOTSTEP_INTERVAL
var suffocate_timer : float = SUFFOCATE_TIME
const SUFFOCATE_TIME = 10.0

const VOLUME_MAX_VELOCITY = 40.0
func _physics_process(delta: float) -> void:
	#print(velocity.length())
	Debug.draw_vector3(velocity, global_position, self, "velocity")
	if player_number != 0: return
	#Debug.push(get_look_dir())
	
	#sfx
	SFX.param_volume(self, "wind", velocity.length() / VOLUME_MAX_VELOCITY)
	
	#animations
	if game_ui.animations.animation != "Shoot":
		game_ui.set_anim("Idle" if vel2D.length() < IDLE_VELOCITY_THRESHOLD else "Walk")
	
	
	
	charge = 1.0
	if Input.is_action_just_pressed("primary_" + str(device_id if device_id != -1 else 0)) and Util.input_group == "default":
		if active_projectile and active_projectile.inactive < 0:
			SFX.play("explode")
			active_projectile.explode()
			active_projectile.queue_free()
		
		elif can_shoot and charge > SHOOT_CHARGE_COST:
			var c = func(): await get_tree().create_timer(SHOOTING_COOLDOWN).timeout; can_shoot = true; 
			c.call()
			can_shoot = false
			charge -= SHOOT_CHARGE_COST
			shoot()
		#print(event.get_action_strength("primary"), shot)
		
	charge = clamp(charge + clamp(vel2D.length(), 0.0, 10.0) * delta * CHARGE_SPEED_MULT, 0.0, 1.0)
	game_ui.texture_progress_bar.value = charge
	#if (gravity_switched and team_one) or (not gravity_switched and not team_one): 
		#game_ui.timer.show()
		#suffocate_timer -= delta
		#game_ui.timer.text = str(ceil(suffocate_timer))
		#if suffocate_timer <= 0:
			#kill()
		
	#else:
		#game_ui.timer.hide()
		#suffocate_timer = clamp(suffocate_timer + delta * 3.0, 0.0, 10.0)
	
	#print(charge)
	#print(Input.get_action_strength("primary"))
	
	if bounce_timer > 0.0: bounce_timer -= delta
	if movement_ctrl_timer > 0.0: movement_ctrl_timer -= delta
	if (is_on_ceiling() and gravity_switched) or (is_on_floor() and not gravity_switched): 
		if can_slide == false:
			SFX.play("land")
		can_slide = true
		
		
		
	if not is_sliding:
		if not using_controller:
			dir = Vector2(Input.get_action_strength("forward") - Input.get_action_strength("backward"), 
			(Input.get_action_strength("left") - Input.get_action_strength("right")) * gravity_mult()).normalized()
		else:
			dir = Vector2(Input.get_action_strength("forward_" + str(device_id)) - Input.get_action_strength("backward_" + str(device_id)), 
			(Input.get_action_strength("left_" + str(device_id)) - Input.get_action_strength("right_" + str(device_id))) * gravity_mult()).normalized()
		
		if Util.input_group != "default": dir = Vector2.ZERO
		
		if dir.length() > DEADZOME:
			vel2D += dir.rotated(rotation.y + PI) * delta * ACCEL
			if (is_on_ceiling() and gravity_switched) or (is_on_floor() and not gravity_switched):
				footstep_timer -= delta
				if footstep_timer < 0.0:
					footstep_timer += min(FOOTSTEP_INTERVAL / vel2D.length(), 0.4)
					SFX.play("footstep")
		
		if vel2D.length() > 0.25:
			vel2D = vel2D.normalized() * (vel2D.length() - (MEGA_DRAG if is_movement_ctrl_pressed else (WEAK_DRAG if vel2D.length() < MAX_SPEED else STRONG_DRAG)) * delta)
		else:
			vel2D = Vector2.ZERO
		
		velocity.z = vel2D.x * delta * 60.0
		velocity.x = vel2D.y * delta * 60.0
		velocity.y -= GRAVITY * delta * gravity_mult() #* (1 + (velocity.y / TERMINAL_VELOCITY)) 
		
		if is_movement_ctrl_pressed and movement_ctrl_timer > 0.0:
			velocity.y = 0
		
		if is_jump_pressed and is_on_wall() and bounce_timer <= 0.0:
			bounce_timer = BOUNCE_TIMER
			bounce()
	
	
	else:
		vel2D = slide_direction * slide_speed
		velocity.x = vel2D.y * delta * 60.0
		velocity.z = vel2D.x * delta * 60.0
		velocity.y -= GRAVITY * delta * (1 + (velocity.y / TERMINAL_VELOCITY)) * gravity_mult()
		
		if is_on_wall():
			is_sliding = false
	
	prev_vel = velocity
	move_and_slide()
	
	if position.y < 0 and not gravity_switched:
		gravity_switched = true
		Util.tween(self, "rotation:z",-PI, 1.0, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		rotate_y(PI)
		MusicController.switch_song("mask_out_dark")
		#flip_anim.play("swap_down")
	
	if position.y > 0 and gravity_switched:
		MusicController.switch_song("mask_out_light")
		gravity_switched = false
		Util.tween(self, "rotation:z", 0.0, 1.0, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		rotate_y(PI)
		#flip_anim.play("swap_up")
	
	
	if using_controller and Util.input_group == "default":
		look_dir = -Vector2((Input.get_action_strength("look_left_" + str(device_id)) - Input.get_action_strength("look_right_" + str(device_id))) * gravity_mult(),
		Input.get_action_strength("look_up_" + str(device_id)) - Input.get_action_strength("look_down_" + str(device_id)))
			
		if not Util.fzero(look_dir.length()):
			var delta_look_dir = look_dir * SENSITIVITY * delta * (ZOOM_SENSITIVITY_EFFECT if zoom else 1.0) * 5.0
			rotation.y += -delta_look_dir.x
			camera.rotation.x = clamp(camera.rotation.x - delta_look_dir.y, Y_CLAMP[0], Y_CLAMP[1])
	
	
	
	if zoom:
		camera.fov = lerpf(camera.fov, FOV * ZOOM_AMMOUNT, delta * ZOOM_SPEED)
	else:
		camera.fov = lerpf(camera.fov, FOV, delta * ZOOM_SPEED)

func jump():
	SFX.play("jump")
	if is_sliding:
		velocity.y = slide_speed * gravity_mult()
		is_sliding = false
		can_slide = true
	else:
		velocity.y = JUMP_VEL * gravity_mult()

func bounce(): 
	SFX.play("bounce")
	velocity = -(prev_vel.reflect(get_wall_normal()) - get_wall_normal())
	vel2D = Vector2(velocity.z, velocity.x)

func get_look_dir():
	return camera.global_position.direction_to(actual_projectile_spawn.global_position)

var shot : bool = false
func _input(event: InputEvent) -> void:
	if is_dead or Util.input_group != "default": return
	#print(event.device)
	if not using_controller:
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			var delta_look_dir = event.relative * SENSITIVITY * 0.005 * (ZOOM_SENSITIVITY_EFFECT if zoom else 1.0)
			rotation.y += -delta_look_dir.x * gravity_mult()
			camera.rotation.x = clamp(camera.rotation.x - delta_look_dir.y, Y_CLAMP[0], Y_CLAMP[1])
	else:
		if device_id != event.device: return
		
		#dir = Vector2(event.get_action_strength("forward_" + str(device_id)) - event.get_action_strength("backward_" + str(device_id)), 
			#event.get_action_strength("left_" + str(device_id)) - event.get_action_strength("right_" + str(device_id))).normalized()
		
	
	if event.is_action_pressed("zoom"):
		SFX.play("scope")
		zoom = true
		crosshair.dot = true
		crosshair.square = false
		crosshair.CROSS_RADIUS = 20.0
		crosshair.flash(1.0)
		
	
	if event.is_action_released("zoom"):
		zoom = false
		crosshair.dot = false
		crosshair.square = true
		crosshair.CROSS_RADIUS = 0
	
	if event.is_action_pressed("jump"):
		is_jump_pressed = true
		if (is_on_ceiling() and gravity_switched) or (is_on_floor() and not gravity_switched):
			jump()
			movement_ctrl_stored_speed = 0.0
			
		elif movement_ctrl_stored_speed != 0.0:
			SFX.play("dash")
			velocity = get_look_dir() * movement_ctrl_stored_speed
			vel2D = Vector2(velocity.z, velocity.x)
			movement_ctrl_stored_speed = 0.0
			is_movement_ctrl_pressed = false
			
	
		
		
		
		
	
	if event.is_action_pressed("grow"):
		#print("a")
		if active_projectile:
			#print("b")
			SFX.play("grow")
			active_projectile.create_vertical_pillar()
			active_projectile.queue_free()
	
	if event.is_action_pressed("hole"):
		if active_projectile:
			SFX.play("hole")
			active_projectile.create_floor_hole()
			#active_projectile.explode()
			active_projectile.queue_free()
				
	
	if event.is_action_pressed("slide") and can_slide:
		is_sliding = true
		can_slide = false
		slide_speed = Vector2(abs(velocity.x), abs(velocity.z)).length()
		slide_direction = dir.rotated(rotation.y + PI)
		
		if Util.fzero(slide_speed):
			slide_speed = MIN_SLIDE_SPEED
			slide_direction = Vector2.RIGHT.rotated(rotation.y + PI)
		else:
			slide_speed = max(slide_speed, MIN_SLIDE_SPEED)
		
		if velocity.y * gravity_mult():
			slide_speed += abs(velocity.y)
	
	if event.is_action_released("slide"):
		#SFX.play("slide")
		if is_sliding: # doinf it this way is nesisiary
			is_sliding = false
			
	if event.is_action_pressed("movement_ctrl"):
		SFX.play("quick_stop")
		is_movement_ctrl_pressed = true
		if movement_ctrl_timer < 1.0:
			
			movement_ctrl_timer = MOVEMENT_CONTROL_VEL_TIME
			movement_ctrl_stored_speed = velocity.length()
	
	if event.is_action_released("movement_ctrl"):
		is_movement_ctrl_pressed = false
	
	if event.is_action_released("jump"):	
		is_jump_pressed = false
	
	#if event.is_action_pressed("test"):
		#mouse_captured = !mouse_captured
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if mouse_captured else Input.MOUSE_MODE_VISIBLE
	
	if event.is_action_pressed("switch_velocity"):
		projectile_mode = Global.ProjectileType.HIGH_VELOCITY if projectile_mode == Global.ProjectileType.LOW_VELOCITY else Global.ProjectileType.LOW_VELOCITY
		crosshair.circle = projectile_mode == Global.ProjectileType.HIGH_VELOCITY
		
var mouse_captured: bool = true

func add_force(force: Vector3):
	velocity.y += force.y
	vel2D += Vector2(force.z, force.x)

var is_dead : bool = false
func kill():
	#print_stack()
	game_ui.win_screen.play_win(team_one)
	global_position = Vector3(0.0, 50.0, 0.0) * (float(team_one) * 2 - 1)
	#if not is_dead:
		#is_dead = true
		#
		#
		##scale = Vector3.ZERO
		#game_ui.dead = true
		#hide()
#
#func revive():
	#if is_dead:
		#is_dead = false
		#global_position = Vector3(0.0, 50.0, 0.0)
		#game_ui.dead = false
		#show()

func shoot():
	if active_projectile : active_projectile.queue_free()
	var inst = PROJECTILE.instantiate()
	# init 
	inst.position = actual_projectile_spawn.global_position
	inst.team_one = team_one
	inst.type = projectile_mode
	
	inst.model_start_pos = model_projectile_spawn.global_position
	inst.player_number = player_number
	inst.init_vel = velocity
	
	# aim assist
	
	if inst.type == Global.ProjectileType.LOW_VELOCITY or not enable_aim_assist or (not using_controller and not aim_assit_kbm):
		# no aim assist for low velocity shots or if its disabled for something
		inst.direction = camera.global_position.direction_to(actual_projectile_spawn.global_position)
	else:
		var inital_shoot_direction : Vector3 = camera.global_position.direction_to(actual_projectile_spawn.global_position)
		var global_player_positions : Array[Vector3]
		var player_velocities : Array[Vector3]
		for player : Player in Global.players:
			if player != self:
				global_player_positions.append(player.global_position)
				player_velocities.append(player.velocity)
		
		if global_player_positions.size() != 0:
			inst.direction = Util.projectile_aim_assist3d(
				global_player_positions, # list of player positions
				player_velocities, # list of player velocities
				inst.position, # bullet position
				inital_shoot_direction, # the aim direction
				inst.PROJECTILE_STATS[Global.ProjectileType.HIGH_VELOCITY]["speed"], # projectile speed
				max_assist_angle_degrees, # max correction angle
				true, # target must be visible
				0.3, # allow people to shoot directly at moving targets, even if thats dumb, I dont wanna snap an unled target to a led one
				controller_assist_curve if using_controller else keyboard_assist_curve, # curve to modulate how the assist works
				speed_assist_max,
				speed_assist_curve if speed_based else null
			)
	Debug.draw_vector3(inst.direction * 3.0, inst.position, self, "", Color.YELLOW)
	Debug.draw_vector3(camera.global_position.direction_to(actual_projectile_spawn.global_position) * 3.0, inst.position, self, "", Color.GREEN)
	
	
	Global.projectile_parent.add_child(inst)
	active_projectile = inst
	
	game_ui.set_anim("Shoot")
	await game_ui.animations.animation_finished
	game_ui.set_anim("Idle" if vel2D.length() < IDLE_VELOCITY_THRESHOLD else "Walk")


func set_debug_pos(to : Vector3):
	var debug_pos : MeshInstance3D = $DebugPos
	debug_pos.show()
	debug_pos.global_position = to


const IDLE_VELOCITY_THRESHOLD = 0.5
