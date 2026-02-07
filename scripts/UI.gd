extends Control
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

var dead : bool = false:
	set(val):
		$ColorRect.visible = dead
		dead = val
@onready var swap: ColorRect = $SWAP
@onready var timer: RichTextLabel = $timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
