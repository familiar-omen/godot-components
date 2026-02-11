@abstract
class_name AbstractComponent extends Node

## The location of components within the meta data of their parent
const component_meta_location = "components"
## Used to prevent needless array creation when calling get_or_set
const blank_dict : Dictionary[GDScript, Array] = {}
## Used to prevent needless array creation when calling get_or_set
const blank_array : Array[AbstractComponent] = []

static var fake_components : Dictionary[GDScript, AbstractComponent] = {}

var entity : Node

## Returns a list of components of the given type attached to the target node
static func get_components(component_script : GDScript, on : Node) -> Array[AbstractComponent]:
	return on.get_meta(component_meta_location, blank_dict).get(component_script, blank_array)

## Returns the first component of the given type attached to the target node
## Returns null and throws a non-blocking error if no components are registered
static func get_component(component_script : GDScript, on : Node) -> AbstractComponent:
	return get_components(component_script, on).front()

## Returns the first component of the given type attached to the target node or its parents(recursive)
## Returns null and throws a non-blocking error if no component is found
static func get_component_recursive(component_script : GDScript, on : Node)  -> AbstractComponent:
	var value = null
	
	while on and not value:
		value = get_components(component_script, on)
		on = on.get_parent()
	
	return value.front()

static func get_safe_component(component_script : GDScript, on : Node) -> AbstractComponent:
	var value = get_components(component_script, on)
	
	if value:
		value = value[0]
	else:
		if fake_components.has(component_script):
			value = fake_components.get(component_script)
		else:
			value = component_script.new()
			fake_components.set(component_script, value)
	
	return value

static func require_component(component_script : GDScript, on : Node) -> AbstractComponent:
	var value = get_components(component_script, on)
	
	if value:
		value = value.front()
	else:
		value = component_script.new(on)
		on.add_child(value)
	
	return value

func _attach_component(to : Node):
	var meta_data : Dictionary[GDScript, Array]
	var components : Array[AbstractComponent]
	var script = self.get_script()
	
	entity = to
	
	meta_data = entity.get_meta(component_meta_location, blank_dict)
	
	if not meta_data:
		meta_data = {}
		entity.set_meta(component_meta_location, meta_data)
	
	components = meta_data.get(script, blank_array)
	
	if not components:
		components = []
		meta_data.set(script, components)
	
	components.append(self)
	
	_component_attached()

func _detach_component():
	_component_dettached()
	get_components(self.get_script(), entity).erase(self)
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
