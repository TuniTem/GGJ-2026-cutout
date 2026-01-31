extends Node

#The size of the buffer in in frames relative to 60FPS
const NORMAL_BUFFER : float = 8.
const SHORT_BUFFER : float = 3.

#The actual size of the buffer in time
const BUFFER_BASE : float = 1./60.

func short_buffer(condition : Callable, function : Callable, args : Array = [] ) -> void:
	custom_buffer(SHORT_BUFFER, condition, function, args)
	
func buffer(condition : Callable, function : Callable, args : Array = [] ) -> void:
	custom_buffer(NORMAL_BUFFER, condition, function, args)

var _var_buffer_info : Dictionary[String, Array]
func var_buffer(name : String, condition : Callable, consume : Callable, arg1 : Array = [], arg2 : Array = []) -> bool:
	if(not _var_buffer_info.has(name)):
		_var_buffer_info[name] = [false, null]
	var buffer_data = _var_buffer_info[name]
	
	var _condition = condition.call(arg1) if arg1.size()>0 else condition.call()
	var _consume = consume.call(arg2) if arg2.size()>0 else consume.call()
	var last_condition = buffer_data[0]
	
	buffer_data[0] = _condition;
	
	if _consume :
		buffer_data[1] = null
		return false
	
	if _condition:
		return true
	
	if last_condition == true and _condition == false:
		buffer_data[1] = get_tree().create_timer(BUFFER_BASE * NORMAL_BUFFER)
		
	var timer : SceneTreeTimer = buffer_data[1]
	if timer != null and timer.time_left > 0:
		return true
	
	return false

#Frames are based on 60 FPS
func custom_buffer(frames : float, condition : Callable, function : Callable, args : Array = [] ) -> void:
	var timer : SceneTreeTimer = get_tree().create_timer(BUFFER_BASE * frames)
	while timer.time_left > 0:
		print(condition.call())
		if condition.call():
			if(args.size() > 0):
				function.call(args)
				return
			function.call()
			return
		await get_tree().process_frame
	#we ran out of time, discard it
