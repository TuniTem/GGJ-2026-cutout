class_name Player
extends CharacterBody3D

var ui : Control

var player_number : int = -1
var using_controller : bool = true
var device_id: int = -1
var song_leader : bool = false

const PROJECTILE = preload("uid://dgpicqgfhtwwf")

@export var crosshair : DrawCrosshair 
@export var actual_projectile_spawn: Marker3D
@export var model_projectile_spawn: Marker3D
@export var animation_player: AnimationPlayer
@export var flip_anim: AnimationPlayer

const SENSITIVITY = 1.0
const FOV = 100

# movement
const MAX_SPEED = 20.0
const ACCEL = 30.0
const GRAVITY = 15.0
const TERMINAL_VELOCITY = 30.0
const WEAK_DRAG = 20.0
const STRONG_DRAG = 40.0
const MEGA_DRAG = 100.0
const DEADZOME = 0.1
const Y_CLAMP = [-PI / 2.0 - 0.1, PI / 2.0 - 0.1]

@export var camera : Camera3D

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
var projectile_mode : Global.ProjectileType = Global.ProjectileType.LOW_VELOCITY
var active_projectile : Area3D
var look_dir : Vector2

func _init() -> void:
	Global.players.append(self)
	player_number = Global.get_player_number(self)
	set_collision_layer_value(player_number + 1, true)
	device_id = Global.request_controller_id(self)
	print(device_id)
	
	if device_id == -1:
		using_controller = false

func _ready() -> void:
	set_collision_layer_value(1, team_one)
	set_collision_layer_value(2, not team_one)

func gravity_mult() -> float:
	return -1.0 if gravity_switched else 1.0

var prev_vel : Vector3
var is_movement_ctrl_pressed : bool = false
var is_jump_pressed : bool = false
var prev_trigger : float = 0.0
const FOOTSTEP_INTERVAL = 5.0
var footstep_timer : float = FOOTSTEP_INTERVAL
func _physics_process(delta: float) -> void:
	charge = clamp(charge + clamp(vel2D.length(), 0.0, 10.0) * delta * CHARGE_SPEED_MULT, 0.0, 1.0)
	print(charge)
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
			
		if dir.length() > DEADZOME:
			vel2D += dir.rotated(rotation.y + PI) * delta * ACCEL
			if (is_on_ceiling() and gravity_switched) or (is_on_floor() and not gravity_switched):
				footstep_timer -= delta
				if footstep_timer < 0.0:
					footstep_timer += min(FOOTSTEP_INTERVAL / vel2D.length(), 0.4)
					SFX.play("footstep")

		vel2D = vel2D.normalized() * (vel2D.length() - (MEGA_DRAG if is_movement_ctrl_pressed else (WEAK_DRAG if vel2D.length() < MAX_SPEED else STRONG_DRAG)) * delta)
		
		velocity.z = vel2D.x * delta * 60.0
		velocity.x = vel2D.y * delta * 60.0
		velocity.y -= GRAVITY * delta * (1 + (velocity.y / TERMINAL_VELOCITY)) * gravity_mult()
		
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
		flip_anim.play("swap_down")
	
	if position.y > 0 and gravity_switched:
		gravity_switched = false
		flip_anim.play("swap_up")
	
	
	if using_controller:
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
		velocity.y = JUMP_VEL

func bounce(): 
	SFX.play("bounce")
	velocity = -(prev_vel.reflect(get_wall_normal()) - get_wall_normal())
	vel2D = Vector2(velocity.z, velocity.x)

func get_look_dir():
	return camera.global_position.direction_to(actual_projectile_spawn.global_position)

func _input(event: InputEvent) -> void:
	
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
		MusicController.slow_down()
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
			
	
	if event.is_action_pressed("primary"):
		if active_projectile and active_projectile.inactive < 0:
			SFX.play("explode")
			active_projectile.explode()
			active_projectile.queue_free()
		
		elif can_shoot and charge > SHOOT_CHARGE_COST:
			var c = func(): await get_tree().create_timer(SHOOTING_COOLDOWN).timeout; can_shoot = true; print("can shoot")
			c.call()
			can_shoot = false
			charge -= SHOOT_CHARGE_COST
			shoot()
			
		
	
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
			active_projectile.explode()
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
	
	if event.is_action_pressed("test"):
		mouse_captured = !mouse_captured
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if mouse_captured else Input.MOUSE_MODE_VISIBLE
			
var mouse_captured: bool = true

func add_force(force: Vector3):
	velocity.y += force.y
	vel2D += Vector2(force.z, force.x)

func shoot():
	
	if active_projectile : active_projectile.queue_free()
	var inst = PROJECTILE.instantiate()
	inst.position = actual_projectile_spawn.global_position
	inst.team_one = team_one
	inst.type = projectile_mode
	inst.direction = camera.global_position.direction_to(actual_projectile_spawn.global_position)
	inst.model_start_pos = model_projectile_spawn.global_position
	inst.player_number = player_number
	Global.projectile_parent.add_child(inst)
	active_projectile = inst
