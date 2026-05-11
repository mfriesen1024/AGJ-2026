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

# bouncy variables
const BOUNCY_ACCEL = 30
const WINDY_MAX_VEL = 5


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

	
	
		

	if(gravity > 0 and is_on_floor()): 
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
		movement_velocity += (BOUNCY_ACCEL * input * delta)
		
	var collision = get_last_slide_collision()
	if(collision):
		
		# TODO figure out how to do bounces (possibly with move_and_collide())
		# the issue I was having is that when you check the velocity at the same tick the collision happens, 
		# it is giving me (i think) the velocity after it collides and zeros out which doesn't help if you want to bounce it
			
		var bounced_vel = velocity.bounce(collision.get_normal())
		print("remainder vel: " + str(collision.get_remainder()) + ", bounced vel: " + str(bounced_vel))

	
	
func handle_windy_movement(delta, input):

	
	if(velocity.length() > WINDY_MAX_VEL): # over max windy speed: decel
		movement_velocity = movement_velocity.lerp(Vector3.ZERO, delta * 10)
	
	elif(input.length() <= 0 && movement_velocity.length() > 0): # decel, no input
		movement_velocity = movement_velocity.lerp(Vector3.ZERO, delta * 50)

	else:
		movement_velocity = WINDY_MAX_VEL * input



func switch_spirit():
	is_bouncy = !is_bouncy
	
