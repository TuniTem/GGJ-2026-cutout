extends Node

# heh u like this variable organization, its really an advanced technique actually...
@onready var slow: AnimationPlayer = $Slow

@export var bus_layout : AudioBusLayout
@export var pitch : float = 1.0:
	set(val):
		for song : String in music.keys():
			music[song].pitch_scale = pitch
		
		pitch = val
@export var tempo: RhythmNotifier

const groups : Dictionary = {
	"mask_out" : ["mask_out_dark", "mask_out_light"],
	"none" : []
}

var curr_group: String = ""
var curr_song: String = "":
	set(val):
		tempo.audio_stream_player = music[val]
		curr_song = val

@onready var music : Dictionary[String, VolumeModifierFlag] = {
	"basic" : %Basic,
	"advanced" : %Adv,
	"light" : %Light,
	"mask_out_dark" : %MaskOutDark,
	"mask_out_light" : %MaskOutLight
}

var _beat_tweens : Array[Dictionary]

func _init() -> void:
	AudioServer.set_bus_layout(bus_layout)

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
	if not music[song].playing: music[song].play()
	var tween : Tween = create_tween()
	tween.tween_property(music[song], "volume_linear", volume_linear * music[song].vol_modifier, time)
	if take_current : curr_song = song
	if stop: 
		await tween.finished
		music[song].stop()

func slow_down():
	slow.play("slow")

func tween_on_beat(
	object : Object, 
	property : NodePath,
	start_val : Variant,  
	final_val : Variant, 
	beat_percentage : float, 
	easing : Tween.EaseType = Tween.EASE_IN, 
	trans : Tween.TransitionType = Tween.TRANS_LINEAR,
	beat_offset : float = 0.0,
	reset : bool = true
):
	_beat_tweens.append({
		"object" : object,
		"property" : property,
		"start_val" : start_val,
		"final_val" : final_val,
		"beat_percentage" : beat_percentage,
		"easing" : easing,
		"trans" : trans,
		"beat_offset" : beat_offset,
		"reset" : reset
	})
	print(_beat_tweens)


func _on_beat(current_interval : int):
	for tween : Dictionary in _beat_tweens:
		if not is_instance_valid(tween["object"]):
			_beat_tweens.erase(tween)
			continue
		
		if tween["reset"]: 
			Util.tween(tween["object"],tween["property"],tween["start_val"], 0.0)
			
		Util.tween(
			tween["object"], 
			tween["property"], 
			tween["final_val"], 
			tween["beat_percentage"] * tempo.beat_length,
			tween["easing"],
			tween["trans"],
			tween["beat_offset"] * tempo.beat_length
		)
