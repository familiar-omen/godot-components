class_name Velocity3D extends Component

signal velocity_changed(velocity : Vector3)
signal velocity_length(size : float)

@export_range(0, 0.4)
var drag : float
var velocity : Vector3:
	set = set_velocity, get = get_velocity

var _external_property : NodePath

func _init() -> void:
	process_physics_priority = 10

func _component_attached():
	if entity is CharacterBody3D: _external_property = ^":velocity"
	elif entity is Node3D: pass
	else: push_error("Unsupported node type: ", entity.get_script())

func set_velocity(value : Vector3):
	velocity_changed.emit(value)
	velocity_length.emit(value.length())
	if _external_property:
		entity.set_indexed(_external_property, value)
	else:
		velocity = value

func get_velocity() -> Vector3:
	if _external_property:
		return entity.get_indexed(_external_property)
	else:
		return velocity

func _physics_process(delta: float) -> void:
	if entity is CharacterBody3D: entity.move_and_slide()
	elif entity is Node3D: entity.global_position += velocity * delta
	velocity = velocity.normalized() * (velocity.length() - velocity.length_squared() * delta * drag)
