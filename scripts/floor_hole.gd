extends CSGBox3D

const SCALE = Vector3(13.0, 1000.0, 13.0)
const PLAYER_BOOST_AMOUNT = 20.0
const EXPAND_MARGIN = 2.0

@onready var ring2: MeshInstance3D = $Ring2
@onready var ring1: MeshInstance3D = $Ring1
@onready var outer: MeshInstance3D = $Outer
@onready var area_3d: Area3D = $Area3D

var flipped : bool = false
var point_towards : Vector3

func _ready() -> void:
	size = SCALE
	#look_at(point_towards, Vector3.UP)
	#rotate_object_local(Vector3.LEFT, PI/2)
	#rotation = rotation.reflect(point_towards - global_position)
	Util.tween(outer, "scale:y", SCALE.y, 1.0, Tween.EASE_IN, Tween.TRANS_CUBIC)
	Util.tween(outer, "position:y", position.y + (SCALE.y * -(-1 if flipped else 1)), 0.5, Tween.EASE_IN, Tween.TRANS_CUBIC)
	
	size.x = SCALE.x
	size.z = SCALE.z
	outer.scale.x = size.x - EXPAND_MARGIN 
	outer.scale.z = size.z - EXPAND_MARGIN 
	ring1.scale.x = size.x - EXPAND_MARGIN 
	ring1.scale.z = size.z - EXPAND_MARGIN 
	ring2.scale.x = size.x - EXPAND_MARGIN 
	ring2.scale.z = size.z - EXPAND_MARGIN 
	
	
	for player : Player in Global.players:
		var pos : Vector3 = player.global_position
		var loc : Vector3 = global_position
		
		if abs(pos.x - loc.x) < size.x - EXPAND_MARGIN and abs(pos.z - loc.z) < size.z - EXPAND_MARGIN:
			#area_3d.
			if player.velocity.y * player.gravity_mult() > 0:
				player.velocity.y = 0.0
			player.add_force(Vector3(0.0, (-player.gravity_mult() * PLAYER_BOOST_AMOUNT), 0.0))
			#player.add_force(
			
			
			
			#player.velocity.y -= player.vel2D.length() * player.gravity_mult()
			#player.vel2D = Vector2.ZERO
			#player.slide_speed = 0.0

func kill():
	Util.tween(self, "size", Vector3.ZERO, 1.0).tween_callback(queue_free)


func _process(delta: float) -> void:
	pass
	#outer.scale = size - 0.5 * Vector3.ONE
