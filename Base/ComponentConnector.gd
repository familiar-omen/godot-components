@icon("res://Icons/nodeXd_component.svg")
class_name ComponentConnector extends Component

signal connected(other : Dictionary[GDScript, Interface])
signal disconnected(other : Dictionary[GDScript, Interface])

@export
var components : Array[Component] = []
var interfaces : Dictionary[GDScript, Interface] = {}

var connections : Dictionary[Node, Dictionary] = {}

func _ready() -> void:
	for component in components:
		for interface in Interface.get_interfaces(component):
			interfaces.set(interface.get_script(), interface)
	
func _component_attached():
	if entity is RayCast3D:
		assert(not components, "Raycasts cant expose components")
	elif entity is Area3D:
		entity.area_entered.connect(add_connection)
		entity.area_exited.connect(remove_connection)
		entity.body_entered.connect(add_connection)
		entity.body_exited.connect(remove_connection)

func _component_dettached():
	if entity is Area3D:
		entity.area_entered.disconnect(add_connection)
		entity.area_exited.disconnect(remove_connection)
		entity.body_entered.disconnect(add_connection)
		entity.body_exited.disconnect(remove_connection)

func _physics_process(_delta: float) -> void:
	if entity is RayCast3D:
		var other = entity.get_collider()
		
		if other not in connections:
			clear_connections()
			add_connection(other)

func add_connection(node : Node):
	if not node: return
	
	var connectors := get_components(ComponentConnector, node)
	
	if connectors and not node in connections:
		connections[node] = connectors.front().interfaces #TODO:: support multiple connectors per hitbox
	
		for connector in connectors:
			connected.emit(connector.interfaces)

func remove_connection(node : Node):
	if node in connections:
		disconnected.emit( connections.get(node))
		connections.erase(node)

func clear_connections():
	for node in connections.keys():
		remove_connection(node)
