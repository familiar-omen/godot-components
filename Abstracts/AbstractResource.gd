@abstract
@icon("res://Icons/node_component.svg")
class_name AbstractResource extends AbstractComponent

signal value_changed(new_value)
signal minimum_exceeded
signal maximum_exceeded

@export 
var maximum : float:
	set = set_maximum

@export_group("Details")
@export var minimum : float
@export_enum("maximum:0", "minimum:1")
var starting_behavior : int = 0
@export_enum("inclusive:0", "exclusive:1")
var minimum_behavior : int = 1
@export_enum("inclusive:0", "exclusive:1")
var maximum_behavior : int = 0

@onready
var  current_value : float = minimum if starting_behavior else maximum:
	set = set_current

var is_full : bool:
	get: return current_value == maximum
var is_empty : bool:
	get: return current_value == minimum

func less_than(exclude_equals : int, a : float, b : float) -> bool:
	match exclude_equals:
		0: return a < b
		1: return a <= b
	return false

func set_current(new_value):
	if less_than(minimum_behavior, new_value, minimum):
		minimum_exceeded.emit()
	
	if less_than(maximum_behavior, maximum, new_value):
		maximum_exceeded.emit()
	
	new_value = clampf(new_value, minimum, maximum)
	
	value_changed.emit(new_value)
	current_value = new_value

func set_maximum(new_maximum):
	maximum = new_maximum
	set_current(current_value)

func reduce(amount : float):
	current_value -= amount

func increase(amount : float):
	current_value += amount
