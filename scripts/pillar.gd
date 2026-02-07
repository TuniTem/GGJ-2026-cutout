extends CSGBox3D

const SCALE = Vector3(5.0, 25.0, 5.0)
const PLAYER_BOOST_AMOUNT = 50.0
const EXPAND_MARGIN = 0.0

@export var ring2: MeshInstance3D
@export var ring1: MeshInstance3D

var flipped : bool = false

func _ready() -> void:
	Util.tween(self, "size:y", SCALE.y / 2.0, 0.5, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	Util.tween(self, "position:y", position.y + (SCALE.y / 4.0 * (-1 if flipped else 1)), 0.5, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	size.x = SCALE.x
	size.z = SCALE.z
	ring1.scale.x = size.x + EXPAND_MARGIN 
	ring1.scale.z = size.z + EXPAND_MARGIN 
	ring2.scale.x = size.x + EXPAND_MARGIN 
	ring2.scale.z = size.z + EXPAND_MARGIN 
	
	
	for player in Global.players:
		var pos : Vector3 = player.global_position
		var loc : Vector3 = global_position
		
		if abs(pos.x - loc.x) < size.x + EXPAND_MARGIN and abs(pos.z - loc.z) < size.z + EXPAND_MARGIN:
			if player.velocity.y * player.gravity_mult() < 0:
				player.velocity.y = 0.0
			player.add_force(Vector3(0.0, (player.gravity_mult() * PLAYER_BOOST_AMOUNT), 0.0))
	

func kill():
	Util.tween(self, "size", Vector3.ZERO, 1.0).tween_callback(queue_free)
