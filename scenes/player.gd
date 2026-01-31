extends CharacterBody3D

var player_number : int = -1

const PROJECTILE = preload("uid://dgpicqgfhtwwf")

@export var crosshair : DrawCrosshair 
@export var actual_projectile_spawn: Marker3D
@export var model_projectile_spawn: Marker3D

const SENSITIVITY = 1.0
const FOV = 100

# movement
const MAX_SPEED = 10.0
const ACCEL = 70.0
const GRAVITY = 9.0
const TERMINAL_VELOCITY = 30.0
const DRAG = 50.0
const DEADZOME = 0.1
const Y_CLAMP = [-PI / 2.0 - 0.1, PI / 2.0 - 0.1]

@export var camera : Camera3D

const JUMP_VEL = 15.0

var vel2D : Vector2 = Vector2.ZERO

# zoom
const ZOOM_AMMOUNT = 0.4
const ZOOM_SPEED = 10.0
const ZOOM_SENSITIVITY_EFFECT = 0.5
var zoom : bool = false

# shooting
var projectile_mode : Global.ProjectileType = Global.ProjectileType.LOW_VELOCITY
var active_projectile : Area3D

func _ready() -> void:
	Global.players.append(self)
	player_number = Global.get_player_number(self)

func _physics_process(delta: float) -> void:
	var dir = Vector2(Input.get_action_strength("forward") - Input.get_action_strength("backward"), 
		Input.get_action_strength("left") - Input.get_action_strength("right")).normalized()
	
	if dir.length() > DEADZOME:
		vel2D += dir.rotated(rotation.y + PI) * delta * ACCEL
		
	vel2D = vel2D.normalized() * clamp(vel2D.length() - DRAG * delta, 0.0, MAX_SPEED)
	
	velocity.z = vel2D.x
	velocity.x = vel2D.y
	velocity.y -= GRAVITY * delta * (1 + (velocity.y / TERMINAL_VELOCITY))
	
	move_and_slide()
	
	if zoom:
		camera.fov = lerpf(camera.fov, FOV * ZOOM_AMMOUNT, delta * ZOOM_SPEED)
	else:
		camera.fov = lerpf(camera.fov, FOV, delta * ZOOM_SPEED)

func jump():
	velocity.y = JUMP_VEL


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var delta_look_dir = event.relative * SENSITIVITY * 0.005 * (ZOOM_SENSITIVITY_EFFECT if zoom else 1.0)
		rotation.y += -delta_look_dir.x
		camera.rotation.x = clamp(camera.rotation.x - delta_look_dir.y, Y_CLAMP[0], Y_CLAMP[1])
	
	if event.is_action_pressed("zoom"):
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
	
	if event.is_action_pressed("jump") and is_on_floor():
		jump()
	
	if event.is_action_pressed("primary"):
		if active_projectile:
			if active_projectile.moving:
				active_projectile.explode()
			else:
				if active_projectile.stick_is_floor:
					active_projectile.create_floor_hole()
				else:
					active_projectile.create_wall_hole()
		else:
			shoot()
	
	if event.is_action_pressed("secondary"):
		if active_projectile:
			if active_projectile.pillard:
				active_projectile.create_floor_hole()
				active_projectile.explode()
			else:
				active_projectile.create_vertical_pillar()
				active_projectile.pillared = true


func add_force(force: Vector3):
	pass

func shoot():
	var inst = PROJECTILE.instantiate()
	inst.position = actual_projectile_spawn.global_position
	inst.type = projectile_mode
	inst.direction = camera.global_position.direction_to(actual_projectile_spawn.global_position)
	inst.model_start_pos = model_projectile_spawn.global_position
	Global.projectile_parent.add_child(inst)
	active_projectile = inst
