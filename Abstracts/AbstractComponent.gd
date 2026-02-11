@abstract
class_name AbstractComponent extends Node

const component_meta_location = "components"
const owned_component_meta_location = "owned_components"
const fake_components : Dictionary[GDScript, AbstractComponent] = {}

var entity : Node
var _next_owner

func _init(initial_owner = null):
	_next_owner = initial_owner

static func get_components(component_script : GDScript, on : Node, owned = false) -> Array[AbstractComponent]:
	var default : Array[AbstractComponent] = []
	var location = owned_component_meta_location if owned else component_meta_location
	return on.get_meta(location, {}).get(component_script, default)

static func get_component(component_script : GDScript, on : Node, owned = false) -> AbstractComponent:
	return get_components(component_script, on, owned).front()

static func get_safe_component(component_script : GDScript, on : Node, owned = false) -> AbstractComponent:
	var value = get_components(component_script, on, owned)
	
	if value:
		value = value.front()
	else:
		if fake_components.has(component_script):
			value = fake_components.get(component_script)
		else:
			value = component_script.new()
			fake_components.set(component_script, value)
	
	return value

static func require_component(component_script : GDScript, on : Node, owned = false) -> AbstractComponent:
	var value = get_components(component_script, on, owned)
	
	if value:
		value = value.front()
	else:
		value = component_script.new(on)
		on.add_child.call_deferred(value)
		#_add_component(value, on, true)
		#value.set.call_deferred("owner", on)
	
	return value

static func _add_component(component : AbstractComponent, to : Node, owned = false) -> Node:
	var location = owned_component_meta_location if owned else component_meta_location
	
	if not to.has_meta(location):
		to.set_meta(location, {})
	
	var meta : Dictionary = to.get_meta(location)
	
	var default : Array[AbstractComponent] = []
	meta.get_or_add(component.get_script(), default).append(component)
	
	return to

static func _remove_component(component : AbstractComponent, from : Node, owned = false) -> Node:
	get_components(component.get_script(), from, owned).erase(component)
	return from

func _notification(what: int) -> void:
	match (what):
		NOTIFICATION_PARENTED:
			if _next_owner:
				owner = _next_owner
				_next_owner = null
			entity = _add_component(self, $"..")
			if owner: _add_component(self, owner, true)
		NOTIFICATION_UNPARENTED:
			_remove_component(self, entity)
			if owner: _remove_component(self, owner, true)
			entity = null
