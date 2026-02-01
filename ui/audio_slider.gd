extends HSlider

@export var bus : String

func _on_value_changed(value: float) -> void:
	Util.set_bus_volume(bus, value, true)
