@abstract
@icon("../Icons/node_component.svg")
class_name Component extends Node

var entity : Node

signal attached(new_entity : Node)
signal detached(old_entity : Node)

func _attach_component(to : Node):
	var meta_data : Dictionary[GDScript, Array]
	var components : Array[Component]
	var script = self.get_script()
	
	entity = to
	
	meta_data = entity.get_meta(Components.component_meta_location, Components.blank_dict)
	
	if not meta_data:
		meta_data = {}
		entity.set_meta(Components.component_meta_location, meta_data)
	
	components = meta_data.get(script, Components.blank_array)
	
	if not components:
		components = []
		meta_data.set(script, components)
	
	components.append(self)
	
	_component_attached()
	attached.emit(entity)

func _detach_component():
	_component_dettached()
	detached.emit(entity)
	entity.get_meta(Components.component_meta_location, Components.blank_dict).get(self.get_script(), Components.blank_array).erase(self)
	entity = null

func _component_attached():
	pass

func _component_dettached():
	pass

func _notification(what: int) -> void:
	match (what):
		NOTIFICATION_PARENTED:
			_attach_component($"..")
		NOTIFICATION_UNPARENTED:
			_detach_component()
