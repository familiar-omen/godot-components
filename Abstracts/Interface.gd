@abstract
class_name Interface extends RefCounted

var _attached_to : Node

func _init(node : Node) -> void:
	register_interface(node)

#func _notification(what: int) -> void:
	#if what == NOTIFICATION_PREDELETE:
		#deregister_interface(_attached_to)

func register_interface(node : Node):
	_attached_to = node
	var interfaces = node.get_meta("interfaces", {})
	
	if not node.has_meta("interfaces"):
		node.set_meta("interfaces", interfaces)
	
	interfaces[self.get_script()] = self

func deregister_interface():
	assert(_attached_to, "Tried to deregister unnatached interface")
	var interfaces : Dictionary = _attached_to.get_meta("interfaces", {})
	_attached_to = null
	
	if interfaces.get(self.get_script()) == self:
		interfaces.erase(self.get_script())

static func get_interface(type : GDScript, node : Node):
	var interfaces : Dictionary = node.get_meta("interfaces", {})
	
	return interfaces.get(type)

static func get_interfaces(node : Node):
	var interfaces : Dictionary = node.get_meta("interfaces", {})
	
	return interfaces.values()
