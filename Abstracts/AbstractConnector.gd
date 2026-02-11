@abstract
@icon("res://Icons/nodeXd_component.svg")
class_name AbstractConnector extends AbstractComponent

signal connected(other_value : Variant)

@abstract 
func get_value()

func _ready() -> void:
	entity.area_entered.connect(hit)
	entity.body_entered.connect(hit)

func hit(otherBase : Node) -> void:
	for other in get_components(self.get_script(), otherBase) as Array[AbstractConnector]:
		connected.emit(other.get_value())
