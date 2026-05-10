extends CharacterBody3D


enum spirit_type { BOUNCY, WINDY, COUNT }

@export var movement_speed = 250
@export var jump_strength = 10
var gravity = 0
var movement_velocity: Vector3
var rotation_direction: float
var can_jump = true


var max_vel: float = 200 #TODO
var horizontal_accel: float = 10
var gravity_accel: float = -9.81



var current_spirit: spirit_type = spirit_type.BOUNCY


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

	move_and_slide()
	
	

func handle_controls(delta):
	
	# Movement

	var input := Vector3.ZERO
	

	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()

	if input.length() > 1:
		input = input.normalized()

	handle_horizontal_accel(delta, input)
	# Jumping

	if Input.is_action_just_pressed("jump"):
		if can_jump:
			jump()
			
	if Input.is_action_just_pressed("switch_spirit"):
		switch_spirit()

func handle_gravity(delta):

	gravity += 25 * delta

	if gravity > 0 and is_on_floor():
		can_jump = true
		gravity = 0

func jump():
	gravity = -jump_strength

	if can_jump:
		can_jump = false;
		
func handle_horizontal_accel(delta, input):
	movement_velocity = velocity + (horizontal_accel * input * delta)
	pass
	
func handle_horizontal_vel(delta, input, has_max_speed = true):
	movement_velocity = input * movement_speed * delta

	pass
	
func handle_vertical_accel(delta, grav_accel):
	pass

















func switch_spirit():
	if(current_spirit + 1 >= spirit_type.COUNT):
		# out of bounds, loop to start
		current_spirit = 0
	else:
		current_spirit += 1
	print("switched to " + str(current_spirit))
