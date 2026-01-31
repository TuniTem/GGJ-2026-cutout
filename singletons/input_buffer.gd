extends Node

#The size of the buffer in in frames relative to 60FPS
const NORMAL_BUFFER : float = 8.
const SHORT_BUFFER : float = 3.

#The actual size of the buffer in time
const BUFFER_BASE : float = 1./60.

func short_buffer(condition : bool, function : Callable, args : Array = [] ) -> void:
	custom_buffer(SHORT_BUFFER, condition, function, args)
	
func buffer(condition : bool, function : Callable, args : Array = [] ) -> void:
	custom_buffer(NORMAL_BUFFER, condition, function, args)


#Frames are based on 60 FPS
func custom_buffer(frames : float, condition : bool, function : Callable, args : Array = [] ) -> void:
	var timer : SceneTreeTimer = get_tree().create_timer(BUFFER_BASE * frames)
	while timer.time_left > 0:
		await get_tree().process_frame
		if condition:
			function.call(args)
			return
	#we ran out of time, discard it
