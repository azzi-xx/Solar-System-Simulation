extends Camera2D

@export var zoom_speed := 0.1
@export var min_zoom := 0.01
@export var max_zoom := 5.0
@export var smooth_zoom := true
@export var drag_sensitivity := 1.0

var target_zoom := 1.0
var is_dragging := false
var drag_start_position := Vector2.ZERO

func _ready() -> void:
	target_zoom = zoom.x

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT: 
			if event.pressed:
				is_dragging = true
				drag_start_position = event.position
				Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			else:
				is_dragging = false
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom -= zoom_speed * target_zoom
			target_zoom = clamp(target_zoom, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom += zoom_speed * target_zoom
			target_zoom = clamp(target_zoom, min_zoom, max_zoom)
	
	elif event is InputEventMouseMotion and is_dragging:
		var drag_offset = (drag_start_position - event.position) * drag_sensitivity / zoom.x
		position += drag_offset
		drag_start_position = event.position

func _process(delta: float) -> void:
	if smooth_zoom:
		zoom = zoom.lerp(Vector2(target_zoom, target_zoom), 10 * delta)
		

		
