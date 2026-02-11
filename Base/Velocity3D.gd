class_name Velocity3D extends AbstractComponent

var velocity : Vector3:
	set = set_velocity, get = get_velocity

## Nodepath from components entity to external property 
var external_property : NodePath

func _component_attached():
	if entity is CharacterBody3D:
		external_property = ^":velocity"

func set_velocity(value : Vector3):
	if external_property:
		entity.set_indexed(external_property, value)
	else:
		velocity = value

func get_velocity() -> Vector3:
	if external_property:
		return entity.get_indexed(external_property)
	else:
		return velocity

func _physics_process(delta: float) -> void:
	if entity is CharacterBody3D:
		entity.move_and_slide()
	elif entity is Node3D:
		entity.global_position += velocity * delta
