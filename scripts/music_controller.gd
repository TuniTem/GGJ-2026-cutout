extends Node


# heh u like this variable organization, its really an advanced technique actually...
@onready var slow: AnimationPlayer = $Slow

@export var pitch : float = 1.0:
	set(val):
		for song : String in music.keys():
			music[song].pitch_scale = pitch
		
		pitch = val

const groups : Dictionary = {
	"mask_out" : ["mask_out_dark", "mask_out_light"],
	"none" : []
}

var curr_group = ""
var curr_song = ""

@onready var music : Dictionary[String, AudioStreamPlayer] = {
	"basic" : %Basic,
	"advanced" : %Adv,
	"light" : %Light,
	"mask_out_dark" : %MaskOutDark,
	"mask_out_light" : %MaskOutLight
}


var playing : String
func prep_group(to : String):
	if curr_group in groups:
		for song : String in groups[curr_group]:
			fade(song, 0.0)
		
		for song : String in groups[to]:
			music[song].play()
			music[song].volume_linear = 0.0
			curr_group = to
			

func switch_song(to : String, time : float = 1.0):
	print("switching song to ", to, " over ", time, "s")
	if curr_song != to:
		if curr_song != "" : fade(curr_song, 0.0, time)
		fade(to, 1.0, time, true)

func fade(song : String, volume_linear : float, time : float = 1.0, take_current : bool = false,  stop : bool = false):
	if volume_linear > 0.0 and not music[song].playing: music[song].play()
	var tween : Tween = create_tween()
	tween.tween_property(music[song], "volume_linear", volume_linear, time)
	if take_current : curr_song = song
	if stop: 
		await tween.finished
		music[song].stop()

func slow_down():
	slow.play("slow")
