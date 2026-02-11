@abstract
@icon("res://Icons/node_component.svg")
class_name AbstractStat extends AbstractComponent

signal value_changed(new_value : float)

func _enter_tree() -> void:
	set_value(value)

@export
var value : float:
	set = set_value

func set_value(new_value : float):
	value_changed.emit(new_value)
	value = new_value
