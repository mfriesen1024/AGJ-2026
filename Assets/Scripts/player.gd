extends CharacterBody3D




@export var movement_speed = 250
@export var jump_strength = 10
const DASH_SPEED = 30
var dashTargetDir: Vector3
var gravity = 0
var movement_velocity: Vector3
var rotation_direction: float
var can_jump: bool = true
var can_dash: bool = false
var can_bounce: bool = true
var is_dashing: bool = false
var is_bouncing: bool = false
var is_falling: bool = false

var is_bouncy: bool = true

# bouncy variables
const BOUNCY_ACCEL = 30
const WINDY_MAX_VEL = 5


func _physics_process(delta):
	# Add the gravity.
	handle_controls(delta)
	handle_gravity(delta)
	

	if(is_bouncing && is_bouncy): # for the brief bouncing window, we track collision
		movement_velocity.y = -gravity
		var collision: KinematicCollision3D = move_and_collide(movement_velocity * delta)
		if(!collision):
			return
		
		is_bouncing = false
		velocity = movement_velocity.bounce(collision.get_normal())
		if(collision.get_normal().y != 0):
			# this is super jank, largely untested but it works for now TODO
			# basically if its not completely vertical switch gravity
			gravity = -gravity
		print("collided")
		return
		
	# if not bouncing, continue with regular sliding movement for ease of use
	
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
	
	# Dash Direction
	
	dashTargetDir = Vector3(input.x * DASH_SPEED,0, input.z * DASH_SPEED);
	
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()

	if input.length() > 1:
		input = input.normalized()

	if Input.is_action_just_pressed("use_skill"):
		use_skill()
		print("Skill Used!")

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
	if(is_dashing):
		gravity = 0
		return
	
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
	

	
	
func handle_windy_movement(delta, input):

	if(is_dashing):
		print(dashTargetDir)
		movement_velocity = movement_velocity.lerp(dashTargetDir, delta * 10)
		print(movement_velocity)
		print("Dash!!!")
	elif(velocity.length() > WINDY_MAX_VEL): # over max windy speed: decel
		movement_velocity = movement_velocity.lerp(Vector3.ZERO, delta * 10)
	elif(input.length() <= 0 && movement_velocity.length() > 0): # decel, no input
		movement_velocity = movement_velocity.lerp(Vector3.ZERO, delta * 50)

	else:
		movement_velocity = WINDY_MAX_VEL * input
		
		
	

func use_skill():
	if(is_bouncy && can_bounce):
		is_bouncing = true
		can_bounce = false
		$bounce_timer.start()
		$bounce_cooldown.start()
		print("Skill use Bounce")
	elif(can_dash):
		is_dashing = true
		can_dash = false
		$dash_timer.start()
		$dash_cooldown.start()
		print("Skill use Zoom")
	
func switch_spirit():
	is_bouncy = !is_bouncy
	can_dash = !can_dash
	can_bounce = !can_bounce
	
func _on_dash_timer_timeout() -> void:
	is_dashing = false
	#print("No Longer Dash")

func _on_bounce_timer_timeout() -> void:
	is_bouncing = false
	#print("No Longer Bounce")

func _on_dash_cooldown_timeout() -> void:
	can_dash = true
	#print("Cooldown End Dash")

func _on_bounce_cooldown_timeout() -> void:
	can_bounce = true
	#print("Cooldown End Bounce")
