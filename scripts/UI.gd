extends Control
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var animations: AnimatedSprite2D = $Control/AnimatedSprite2D

var dead : bool = false:
	set(val):
		$ColorRect.visible = dead
		dead = val
@onready var swap: ColorRect = $SWAP
@onready var timer: RichTextLabel = $timer
@export var win_screen: Control

func set_anim(to : String):
	animations.play(to)
