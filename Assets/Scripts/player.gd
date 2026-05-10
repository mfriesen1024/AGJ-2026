extends CharacterBody3D




@export var movement_speed = 250
@export var jump_strength = 10
var gravity = 0
var movement_velocity: Vector3
var rotation_direction: float
var can_jump: bool = true
var is_falling: bool = false

var is_bouncy: bool = true

var vel_last_tick:Vector3 


func _physics_process(delta):
	# Add the gravity.
	handle_controls(delta)
	handle_gravity(delta)
	
	# Rotation

	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()

	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)
		
	var applied_velocity: Vector3

	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity

	velocity = applied_velocity

	move_and_collide(velocity * delta)
	
	vel_last_tick = velocity

func handle_controls(delta):
	
	# Movement

	var input := Vector3.ZERO
	

	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()

	if input.length() > 1:
		input = input.normalized()

	if(is_bouncy):
		handle_bouncy_movement(delta, input)
	else:
		handle_windy_movement(delta, input)
	
	
	# Jumping

	if Input.is_action_just_pressed("jump"):
		if can_jump:
			jump()
			
	if Input.is_action_just_pressed("switch_spirit"):
		switch_spirit()

func handle_gravity(delta):

	gravity += 25 * delta

	
	if(is_on_floor() && can_jump == false):
		# landed this tick
		# print("landed")
		can_jump = true
		

	elif(gravity > 0 and is_on_floor()): 
		can_jump = true
		is_falling = false
		gravity = 0
		


func jump():
	gravity = -jump_strength

	if can_jump:
		can_jump = false;
		is_falling = true;
		
		
func handle_bouncy_movement(delta, input):
	
	
	if(input.length() <= 0 && movement_velocity.length() > 0): # decel, no input
		movement_velocity = movement_velocity.lerp(Vector3.ZERO, delta * 1)
		
	else:  # accel
		movement_velocity = velocity
		movement_velocity += (30 * input * delta)
		
	var collision = get_last_slide_collision()
	if(collision):
		print("collision")
	
		var bounced_vel = velocity.bounce(collision.get_normal().normalized())
		print("last tick vel: " + str(get_position_delta()) + ", bounced vel: " + str(bounced_vel))
		
	
	
func handle_windy_movement(delta, input):
	var max_vel = 5
	
	if(velocity.length() > max_vel): # over max windy speed: decel

		movement_velocity = movement_velocity.lerp(Vector3.ZERO, delta * 10)
	
	elif(input.length() <= 0 && movement_velocity.length() > 0): # decel, no input
		movement_velocity = movement_velocity.lerp(Vector3.ZERO, delta * 50)


	
		
	else:
		movement_velocity = 5 * input

	pass
		

	
	
















func switch_spirit():
	is_bouncy = !is_bouncy
	
