extends Node

var mouse_captured : bool = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func  _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_mouse_control"):
		mouse_captured = !mouse_captured
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if mouse_captured else Input.MOUSE_MODE_VISIBLE
	
