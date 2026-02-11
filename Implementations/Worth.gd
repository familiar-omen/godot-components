@icon("res://Icons/node_component.svg")
class_name Worth extends StatComponent

func _ready() -> void:
	entity.tree_exited.connect(print.bind("player gained ", value, " gold"))
