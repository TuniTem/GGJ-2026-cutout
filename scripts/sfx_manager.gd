extends Node

@onready var sounds : Dictionary[String, AudioStreamPlayer] = {
	"eclipso_win" : %EclipsoWin, 
	"lunaire_win" : %LunaireWin,
	"footstep": %Footstep, #
	"countdown" : %Countdown,
	"shoot_low" : %ShootLowPower,#
	"shoot_high" : %ShootHighPower,#
	"grow" : %GrowPillar,#
	"hole" : %CreateHole,#
	"explode" : %ProjectileExplode,#
	"scope" : %Scope, #
	"bounce" : %Bounce, #
	"dash" : %Dash, #
	"slide" : %Slide, #
	"jump" : %Jump, #
	"land" : %Land,#
	"quick_stop" : %QuickStop,#
	"swap" : %Swap,
	"wind" : %Wind,
	"crash" : %Crashout
	
}

func param_volume(node : Object, sound : String, value : float):
	value = clamp(value, 0.0, 1.0)
	var id : String = sound + "_" + str(node.get_instance_id())
	if not sounds.has(id):
		var inst : AudioStreamPlayer = sounds[sound].duplicate()
		inst.name = id
		sounds[id] = inst
		add_child(inst)
	
	var audio_player : VolumeModifierFlag = sounds[sound]
	
	if not audio_player.playing and value != 0.0: 
		audio_player.play()
	
	elif value == 0.0:
		audio_player.stop()
	
	audio_player.volume_linear = value * audio_player.vol_modifier

func play(sound : String):
	sounds[sound].play()
