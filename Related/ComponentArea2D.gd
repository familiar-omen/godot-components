class_name ComponentArea2D extends Area2D

signal component_connected(component : AbstractComponent)
signal component_disconnected(component : AbstractComponent)

@export
var components : Array[AbstractComponent] = []

func _ready() -> void:
	area_entered.connect(connect_with_other)
	area_exited.connect(connect_with_other)

func connect_with_other(other):
	if other is ComponentArea2D:
		for component in other.components:
			component_connected.emit(component)

func disconnect_with_other(other):
	if other is ComponentArea2D:
		for component in other.components:
			component_disconnected.emit(component)
