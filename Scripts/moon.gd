extends RigidBody2D
@export var central_body: RigidBody2D
@export var grav_cons: float = 50000.0
@export var trail_duration: float = 10.0
@export var trail_max_points: int = 200

@onready var trail: Line2D = $Trail

func _ready():
	if not trail:
		print("Error, Add a line2d node as a child")
		return
		
	trail.width = 2.0
	trail.default_color = Color.WHITE
	
	if central_body:
		var orbital_radius = global_position.distance_to(central_body.global_position)
		#getting the disntance from the body being orbitted
		
		var perfect_velocity = sqrt(grav_cons * central_body.mass / orbital_radius)
		#formula to calculate the perfect velocity needed to have a stable orbit
		
		var direction_to_center = global_position.direction_to(central_body.global_position)
		
		var tangential_direction = Vector2(-direction_to_center.y, direction_to_center.x).normalized()
		#getting a vector to point from the central body to the main body
		#Then rotating that vector 90degrees counter clockwise
		#Then normalizing it by converting it to the unit vector which always have a magnitude of 1
		
		linear_velocity = tangential_direction * perfect_velocity
		#self explanatory, the linear velocity needed to have a stable orbit
		#just need to apply it to the main body
		
		
func _physics_process(_delta):
	if not central_body:
		return
	
	update_trail()
		
	var direction = central_body.global_position - global_position
	#makes another vector that spans the space between the 2 points
	
	var distance = direction.length()
	#gets the magnitude of the vector created. Getting the disntacne between the 2 vector
	
	#debug
	print("Distance: %.2f" % (distance))
	print("Moon mass: %.2f" % mass)
	print("Earth mass: %.2f" % central_body.mass)
	print("Current velocity: %.2f" % linear_velocity.length())
	
	if distance < 10:
		print("TOO CLOSE!")
		return

	direction = direction / distance
	#this gets the actual direction. Without the distance involved
	#Unit Vector. It's always 1
	
	var force_magnitude = grav_cons * (mass * central_body.mass) / (distance * distance)
	#Newton's gravity formula
	# grav_cons being the gravitational constant
	# mass being the mass of the orbiting body
	# central_body.mass being the mass of the body that's being orbited
	
	#I think this code also applies to the central body
	
	var gravitational_force = direction * force_magnitude
	apply_central_force(gravitational_force)
	#The centripetal force acting on the orbiting body
	
func update_trail():
	if not trail:
		return
	trail.add_point(global_position)
	#add the current position of the body to the trail
	
	var points_to_keep = int(trail_duration * 60)
	if trail.get_point_count() > points_to_keep:
		trail.remove_point(0)
		
	
	
	
		
