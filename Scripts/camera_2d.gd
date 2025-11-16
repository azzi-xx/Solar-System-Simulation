extends Camera2D

@export var pan_speed := 5000.0
@export var zoom_speed := 0.1
@export var min_zoom := 0.01
@export var max_zoom := 5.0
@export var smooth_zoom := true

var target_zoom := 1.0

func _ready() -> void:
	target_zoom = zoom.x
	
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_just_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_just_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_just_pressed("ui_up"):
		velocity.y -= 1

	if velocity != Vector2.ZERO:
		position += velocity.normalized() * pan_speed * delta / zoom.x
	if smooth_zoom:
		zoom = zoom.lerp(Vector2(target_zoom, target_zoom), 10 * delta)
		
#func _input(event):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#target_zoom += zoom_speed
		#if event.button_index == MOUSE_BUTTON_RIGHT:
			#target_zoom -= zoom_speed
			#
		#target_zoom = clamp(target_zoom, min_zoom, max_zoom)
		
