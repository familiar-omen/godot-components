@icon("res://Icons/node2d_component.svg")
class_name Velocity2 extends AbstractComponent

var velocity : Vector2:
	set = set_velocity
	
func set_velocity(value : Vector2):
	velocity = value

func _physics_process(delta: float) -> void:
	if entity is CharacterBody2D:
		entity.velocity = velocity
		entity.move_and_slide()
	elif entity is Node2D:
		entity.global_position += velocity * delta
