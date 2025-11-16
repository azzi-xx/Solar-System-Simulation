extends Line2D

@export var body: RigidBody2D
@export var fade_speed := .5
@export var max_points := 100
var fade_time := 2.0
var fading := false

func _ready():
	if body:
		body.tree_exiting.connect(_start_fade)
		
func _start_fade():
	fading = true
	
func _process(delta: float):
	if not fading:
		var pos = body.global_position
		add_point(to_local(pos))
		if points.size() > max_points:
			remove_point(0)
	else:
		modulate.a -= delta / fade_time
		if modulate.a <= 0:
			queue_free()

	
