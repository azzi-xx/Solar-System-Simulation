extends Node

var bodies: Array = []
@export var grav_cons: float = 50000.0

func register_body(body):
	if body not in bodies:
		bodies.append(body)
		print("Registered: " + body.name)
#register's every celestial body in the scene

func unregister_body(body):
	bodies.erase(body)
	
func calculate_net_force_on(body):
	var total_force = Vector2.ZERO
	for other_body in bodies:
		if other_body != body and is_instance_valid(other_body):
			total_force += calculate_gravitational_force(body, other_body)
	return total_force
#Where every celestial body is compared to each other and for each one of those, adds a vector force
#to the total force being applied to the body
	
func calculate_gravitational_force(a, b) -> Vector2:
	var dir = b.global_position - a.global_position
	var dist = dir.length()
	
	if dist < 50:
		return Vector2.ZERO
		
	dir = dir.normalized()
	var force = grav_cons * (a.mass * b.mass) / (dist * dist)
	return dir * force

#Implementing Newton's law of Universal Gravitation
#F = G * (m1 * m2) / r^2
#
func get_center_of_mass() -> Vector2:
	var total_mass = 0.0
	var weighted_position = Vector2.ZERO
	
	for body in bodies:
		total_mass += body.mass
		weighted_position += body.global_position * body.mass
		
	if total_mass > 0:
		return weighted_position / total_mass
	else:
		return Vector2.ZERO

func get_total_system_mass() -> float:
	var total = 0.0
	for body in bodies:
		total += body.mass
	return total
	
		
		
		
		
