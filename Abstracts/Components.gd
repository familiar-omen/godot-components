@abstract
class_name Components extends Object

## The location of components within the meta data of their parent
const component_meta_location = "components"
## Used to prevent needless array creation when calling get_or_set
const blank_dict : Dictionary[GDScript, Array] = {}
## Used to prevent needless array creation when calling get_or_set
const blank_array : Array[Component] = []

## Lets reduce overhead on fake components by only making one of each
static var fake_components : Dictionary[GDScript, Component] = {}

## Return all instances of the component in the seach area
static func get_all(component_type : GDScript) -> component_query:
	return component_query.new(component_type, _get_all)

## Return the first component in the seach area
static func get_first(component_type : GDScript) -> component_query:
	return component_query.new(component_type, _get_first)

## Return the first component in the seach area or add it to the search root
static func get_or_add(component_type : GDScript) -> component_query:
	return component_query.new(component_type, _get_or_add)

## Return the first component in the seach area or return a dummy
## WARNING: Reading from the dummy will yield unpredictable values
static func get_or_fake(component_type : GDScript) -> component_query:
	return component_query.new(component_type, _get_or_add)

static func _get_first(_core : Node, type : GDScript, iterator):
	for node in iterator:
		var value = node.get_meta(component_meta_location, blank_dict).get(type, blank_array)
		if value: return value.front()
	return null

static func _get_all(_core : Node, type : GDScript, iterator):
	var components = []
	for node in iterator:
		var value = node.get_meta(component_meta_location, blank_dict).get(type, blank_array)
		if value: components.append_array(value)
	return components

static func _get_or_add(core : Node, type : GDScript, iterator):
	var value = _get_first(core, type, iterator)
	
	if not value:
		value = type.new()
		core.add_child(value)
	
	return value

static func _get_or_fake(core : Node, type : GDScript, iterator):
	var value = _get_first(core, type, iterator)
	
	if not value:
		if fake_components.has(type):
			value = fake_components.get(type)
		else:
			value = type.new()
			fake_components.set(type, value)
	
	return value

class component_query:
	var _type : GDScript
	var _function : Callable
	
	func _init(type, function):
		_type = type
		_function = function
	
	## Only seach the singular node for attached components
	func on(node : Node):
		return _function.call(node, _type, IterateSingle.new(node))
	
	## Search the node and all its owned children in tree order
	func owned_by(node : Node):
		return _function.call(node, _type, IterateOwned.new(node))
	
	## Search the node and all its children in tree order
	func on_children_of(node : Node):
		return _function.call(node, _type, IterateChildren.new(node))
	
	## Search the node and its ancestors in reverse tree order
	func on_ancestors_of(node : Node):
		return _function.call(node, _type, IterateAncestors.new(node))

class IterateSingle:
	var _search_root : Node

	func _init(search_root):
		_search_root = search_root

	func _iter_init(iter):
		iter[0] = _search_root
		return true

	func _iter_next(_iter):
		return false

	func _iter_get(iter):
		return iter

class IterateAncestors extends IterateSingle:
	func _iter_next(iter):
		iter[0] = iter[0].get_parent()
		
		return iter[0] != null

class IterateOwned extends IterateSingle:
	func _iter_next(iter):
		var index = -1
		var parent = iter[0]
		var searching = true
		var child : Node
		
		while searching:
			index += 1
			while index >= parent.get_child_count():
				index = parent.get_index() + 1
				parent = parent.get_parent()
				if not parent: return false
			
			child = parent.get_child(index)
			if not _search_root.is_ancestor_of(child): return false
			searching = child.owner != _search_root
		
		iter[0] = child
		
		return true

class IterateChildren extends IterateSingle:
	func _iter_next(iter):
		var index = 0
		var parent = iter[0]
		
		while index >= parent.get_child_count():
			index = parent.get_index() + 1
			parent = parent.get_parent()
			if not parent: return false
		
		var child = parent.get_child(index)
		if not _search_root.is_ancestor_of(child): return false
		iter[0] = child
		
		return true
