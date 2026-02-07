extends Node


const DUMMY_VIEWPORT_IMAGES = [
	preload("uid://djovo05un28dv"),
	preload("uid://c0qemv0dgfahb"),
	preload("uid://chogc5scvav3s"),
	preload("uid://fy6t4lcfp7sb"),
	preload("uid://hsqifgs8wgiq")
]

@onready
var GRID_CONTAINER = $GridContainer

var windows = []

func _init() -> void:
	Signals.start_splitscreen.connect(_on_start_splitscreen)
	Signals.game_win.connect(_on_game_win)
	pass

func _ready() -> void:
	Signals.start_splitscreen.emit(Global.player_count, Global.use_subwindows)
	
func _on_game_win():
	#Delete all players
	for player in Global.players:
		player.queue_free()
	
	if(!Global.use_subwindows):
		get_tree().change_scene_to_packed(GameManger.WINSCREEN)
		return
		pass
	
	#load up the scene on to all windows
	for window in windows:
		var winscreen = GameManger.WINSCREEN.instantiate()
		window.add_child(winscreen)
		# * 1.65 to get to 1920 x 1080
		# We are gonna scale based on y
		window.size_changed.connect(
			func(): 
				winscreen.scale = Vector2.ONE * (window.size.x / 1920) * 1.65)
		#we need to scale to the size of the window
		await get_tree().process_frame #hella jank
		winscreen.scale = Vector2.ONE * (window.size.x / 1920.) * 1.65
		pass	
	pass
	
func _on_start_splitscreen(player_count : int, use_subwindows : bool) -> void:
	if use_subwindows:
		for i in player_count:
			setup_windows(true)
		Signals.game_start.emit()
		return
	for i in player_count:
		setup_viewport()
	if(player_count % 2 != 0): #we only ever need one dummy viewport
		dummy_viewport()
	Signals.game_start.emit()	
	pass
	


func dummy_viewport():
	var text_rect = TextureRect.new()
	text_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_rect.texture = DUMMY_VIEWPORT_IMAGES.pick_random()
	text_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	GRID_CONTAINER.add_child(text_rect)
	pass

var subviewports : Array[SubViewport] 

func setup_windows(use_multi_monitor : bool):
	var resolution = DisplayServer.window_get_size()
	var window = Window.new()
	windows.append(window)
	self.add_child(window)
	var player : Player = GameManger.spawn_player(Vector3.ZERO, window)
	var player_number = Global.get_player_number(player)
	if(!use_multi_monitor):
		window.size = resolution / 2
		window.position = Vector2(window.size.x * (player_number % 2), window.size.y)
	else:
		window.size = Vector2(1920, 1080)
		window.position = Vector2(window.size.x * player_number, 0)
	
	var team = int(player.team_one) * 2 - 1
	player.position.y = 21. * team
	player.model_helper.set_team_colors((int(player.team_one) + 1) as Global.Team)
	player.position.x = randf_range(-20, 20.)
	player.position.z = randf_range(-20., 20.)
	
	var crosshair : DrawCrosshair = GameManger.CROSSHAIR.instantiate()
	crosshair.position = window.size / 2.
	crosshair.FREE_ROTATION = 0.
	
	player.get_parent().add_child(crosshair)
	
	player.crosshair = crosshair
	
	window.size_changed.connect(func(): crosshair.position = window.size/2)
	await get_tree().process_frame #hella jank
	crosshair.position = window.size/2

func setup_viewport():	
	
	var subviewportcontianer = SubViewportContainer.new()
	var subviewport = SubViewport.new()
	var player : Player = GameManger.spawn_player(Vector3.ZERO, subviewport)
	var player_number = Global.get_player_number(player)
	
	subviewportcontianer.stretch = true
	subviewportcontianer.name = "Player " + str(player_number)
	subviewportcontianer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subviewportcontianer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	subviewportcontianer.add_child(subviewport)
	GRID_CONTAINER.add_child(subviewportcontianer)
	
	var team = int(player.team_one) * 2 - 1
	player.position.y = 21. * team
	player.position.x = randf_range(-20, 20.)
	player.position.z = randf_range(-20., 20.)
	
	var crosshair : DrawCrosshair = GameManger.CROSSHAIR.instantiate()
	crosshair.position = subviewportcontianer.size / 2.
	crosshair.FREE_ROTATION = 0.
	
	subviewport.add_child(crosshair)
	
	player.crosshair = crosshair
	
	get_viewport().size_changed.connect(func(): crosshair.position = subviewportcontianer.size/2)
	await get_tree().process_frame #hella jank
	crosshair.position = subviewportcontianer.size/2
	pass
