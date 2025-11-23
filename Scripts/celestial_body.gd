extends RigidBody2D
class_name CelestialBody

@export var orbit_eccentricity: float = 1.0
@export var orbit_target_path: NodePath
@export var is_sun := false
@export var label_offset := Vector2(0, 0)

var mass_label: Label
var camera: Camera2D

func _ready():
	add_to_group("celestial_bodies")
	GravityManager.register_body(self)
	await get_tree().process_frame
	setup_initial_orbit()
	
	if is_sun:
		contact_monitor = true
		max_contacts_reported = 10
		body_entered.connect(_on_sun_body_entered)
	
	camera = get_viewport().get_camera_2d()
	
	create_mass_label()
	update_font_scale()

func create_mass_label():
	mass_label = Label.new()
	update_mass_label()
	mass_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mass_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	mass_label.add_theme_font_size_override("font_size", 16)
	mass_label.add_theme_color_override("font_color", Color.WHITE)
	
	mass_label.add_theme_constant_override("outline_size", 2)
	mass_label.add_theme_color_override("font_outline_color", Color.BLACK)
	
	mass_label.position = label_offset
	add_child(mass_label)

func update_mass_label():
	if mass_label:
		mass_label.text = str(mass)

func _process(_delta):
	if mass_label:
		mass_label.position = label_offset
		
		mass_label.rotation = -rotation

	update_font_scale()

func update_font_scale():
	if mass_label and camera:
		var zoom_factor = 1.0 / camera.zoom.x
		var new_font_size = int(16 * zoom_factor)
		mass_label.add_theme_font_size_override("font_size", new_font_size)

func show_mass():
	if mass_label:
		mass_label.visible = true
		update_font_scale()

func hide_mass():
	if mass_label:
		mass_label.visible = false

func toggle_mass_display():
	if mass_label:
		mass_label.visible = !mass_label.visible
		if mass_label.visible:
			update_font_scale()

func _on_sun_body_entered(body):
	if is_sun and body is CelestialBody and not body.is_sun:
		print("SUN: Consumed ", body.name)
		GravityManager.unregister_body(body)
		body.queue_free()
	
func setup_initial_orbit():
	var target = get_node_or_null(orbit_target_path)
	
	if target and target is CelestialBody:
		#var center_of_mass = GravityManager.get_center_of_mass()
		var distance_to_center = global_position.distance_to(center_of_mass)
		var total_system_mass = GravityManager.get_total_system_mass()
		var circular_velocity = sqrt(GravityManager.grav_cons * total_system_mass / distance_to_center)
		var orbital_velocity = circular_velocity * orbit_eccentricity
		
		var direction_to_center = global_position.direction_to(center_of_mass)
		var tangential_direction = Vector2(-direction_to_center.y, direction_to_center.x).normalized()
		linear_velocity = tangential_direction * orbital_velocity
	else:
		linear_velocity = Vector2.ZERO
		print(name, " is central body - no initial velocity")
		
func _physics_process(_delta):
	var net_force = GravityManager.calculate_net_force_on(self)
	apply_central_force(net_force)
	
func _exit_tree():
	GravityManager.unregister_body(self)
		
		
