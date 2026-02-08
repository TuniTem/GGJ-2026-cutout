
extends Object

var list : Array[String]:
	get(): return commands.keys()

var commands : Dictionary[String, Dictionary] = {
	"help" : {
		"execute" : 
			func(_args : Array):
				Debug.push("List of avalable commands:", Debug.INFO)
				for command in list:
					Debug.push("\t"+command, Debug.INFO)
,
		"autocomplete": 
			func(_last_word : String):
				match _last_word:
					#"item": return Global.ITEM_LIST
					_: return []
,
	}
}
