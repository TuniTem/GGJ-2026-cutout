extends Control
@export var level_to_load : PackedScene
@export var button_hover_sfx : AudioStream
@export var button_click_sfx : AudioStream
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func button_hovered() -> void:
	$AudioStreamPlayer2D.stream = button_hover_sfx
	$AudioStreamPlayer2D.play()

func _on_play_button_pressed() -> void:
	$AudioStreamPlayer2D.stream = button_click_sfx
	$AudioStreamPlayer2D.play()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_packed(level_to_load)
	
	pass # Replace with function body.


func _on_play_button_mouse_entered() -> void:
	button_hovered()
func _on_quit_button_mouse_entered() -> void:
	button_hovered()
