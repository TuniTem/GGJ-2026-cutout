extends Node

#The size of the buffer in in frames relative to 60FPS
const BUFFER_FRAME : float = 5.

#The actual size of the buffer in time
const BUFFER_TIME : float = 1./60. * BUFFER_FRAME

func buffer(condition : bool, function : Callable, args : Array ) -> void:
	var timer : SceneTreeTimer = get_tree().create_timer(BUFFER_TIME)
	while timer.time_left > 0:
		await get_tree().process_frame
		if condition:
			function.call(args)
			return
	#we ran out of time, discard it
