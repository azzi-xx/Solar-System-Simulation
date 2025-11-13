extends Line2D

@export var body: RigidBody2D
@export var fade_speed := .5
@export var max_points := 100

func _process(delta: float) -> void:
	var pos = body.global_position
	add_point(to_local(pos))
	if points.size() > max_points:
		remove_point(0)
		

	
