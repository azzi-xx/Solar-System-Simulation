extends RigidBody2D
class_name CelestialBody

@export var orbit_eccentricity: float = 1.0
@export var orbit_target_path: NodePath
@export var is_sun := false

func _ready():
	GravityManager.register_body(self)
	await get_tree().process_frame
	setup_initial_orbit()
	
	if is_sun:
		contact_monitor = true
		max_contacts_reported = 10
		body_entered.connect(_on_sun_body_entered)

func _on_sun_body_entered(body):
	if is_sun and body is CelestialBody and not body.is_sun:
		print("SUN: Consumed ", body.name)
		GravityManager.unregister_body(body)
		body.queue_free()
	
func setup_initial_orbit():
	var target = get_node_or_null(orbit_target_path)
	
	if target and target is CelestialBody:
		var center_of_mass = GravityManager.get_center_of_mass()
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
		
		
