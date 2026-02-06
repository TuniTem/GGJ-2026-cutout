extends CanvasLayer
@export var level_to_load : PackedScene
@export var button_hover_sfx : AudioStream
@export var button_click_sfx : AudioStream

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	var show := not visible
	visible = show
	get_tree().paused = show
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if show else Input.MOUSE_MODE_CAPTURED

func button_hovered_audio() -> void:
	$AudioStreamPlayer2D.stream = button_hover_sfx
	$AudioStreamPlayer2D.play()

func button_pressed_audio() -> void:
	$AudioStreamPlayer2D.stream = button_click_sfx
	$AudioStreamPlayer2D.play()

func _process(delta: float) -> void:
	pass


func _on_main_menu_button_pressed() -> void:
	button_pressed_audio()
	await get_tree().create_timer(0.25).timeout
	toggle_pause()
	get_tree().change_scene_to_packed(level_to_load)


func _on_main_menu_button_mouse_entered() -> void:
	button_hovered_audio()


func _on_reset_level_button_pressed() -> void:
	get_tree().reload_current_scene()
	toggle_pause()
	button_pressed_audio()


func _on_reset_level_button_mouse_entered() -> void:
	button_hovered_audio()


func _on_resume_button_pressed() -> void:
	button_pressed_audio()
	toggle_pause()


func _on_resume_button_mouse_entered() -> void:
	button_hovered_audio()
