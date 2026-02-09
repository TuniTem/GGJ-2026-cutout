extends CanvasLayer
@export var level_to_load : PackedScene
@export var button_hover_sfx : AudioStreamPlayer
@export var button_click_sfx : AudioStreamPlayer
@onready var splat: ParallaxNode = %Splat
@onready var big_text: ParallaxNode = %BigText
@onready var small_text: ParallaxNode = %SmallText
@onready var lobby_code: LineEdit = %LobbyCode
@onready var host: Button = %Host
@onready var copy: Button = %Copy


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	MusicController.tween_on_beat(splat, "modulate:a", 0.5, 1.0, 1.0, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	MusicController.tween_on_beat(big_text, "scale", Vector2.ONE, Vector2.ONE * 1.1, 1.0, Tween.EASE_OUT, Tween.TRANS_LINEAR)
	MusicController.tween_on_beat(small_text, "scale", Vector2.ONE, Vector2.ONE * 1.05, 1.0, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	visible = not visible
	#get_tree().paused = show
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  
		Util.set_input_group("pause")
		if Net.is_host:
			copy.show()
			host.hide()
		else:
			copy.hide()
			host.show()
			host.disabled = false
			
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Util.set_input_group("default")
		lobby_code.hide()

func _process(delta: float) -> void:
	pass

func _on_main_menu_button_pressed() -> void:
	button_click_sfx.play()
	await get_tree().create_timer(0.25).timeout
	toggle_pause()
	get_tree().change_scene_to_packed(level_to_load)


#func _on_reset_level_button_pressed() -> void:
	#get_tree().reload_current_scene()
	#toggle_pause()
	#button_click_sfx.play()

func _on_resume_button_pressed() -> void:
	button_click_sfx.play()
	toggle_pause()


func _on_mouse_entered() -> void:
	button_hover_sfx.play()


func _on_quit_game_pressed() -> void:
	button_click_sfx.play()
	await Util.wait(0.25)
	get_tree().quit()


func _on_host_pressed() -> void:
	#toggle_pause()
	host.disabled = true
	await Net.create_lobby()
	copy.show()
	host.hide()
	_on_copy_pressed()


func _on_join_pressed() -> void:
	lobby_code.show()
	lobby_code.grab_focus(true)


func _on_lobby_code_text_submitted(new_text: String) -> void:
	if int(new_text) != 0:
		Net.join_lobby(int(new_text))
	else:
		lobby_code.hide()


func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(str(Net.lobby_id))
	copy.disabled = true
	copy.get_node("RichTextLabel").text = "[color=white][wave amp=10.0]CODE COPPIED!"
	await Util.wait(1.5)
	copy.disabled = false
	copy.get_node("RichTextLabel").text = "[wave amp=10.0]COPY CODE"
	
