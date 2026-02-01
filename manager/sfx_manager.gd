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
	"swap" : %Swap
	
}

func play(sound : String):
	sounds[sound].play()
