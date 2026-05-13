extends CharacterBody3D

# General variables
@export var movement_speed = 250
@export var jump_strength = 10
var gravity = 0
var movement_velocity: Vector3
var rotation_direction: float
var can_jump: bool = true
var can_swap_spirits: bool = true

# Bouncy variables
const BOUNCY_ACCEL = 5
var can_bounce: bool = true
var is_bouncing: bool = false
var is_bouncy: bool = true
var is_falling: bool = false

# Zoomy variables
const WINDY_ACCEL = 5.75
const WINDY_MAX_VEL = 10
const DASH_SPEED = 30
var dashTargetDir: Vector3
var can_dash: bool = false
var is_dashing: bool = false

#func _on_ready():
	#PlayerVariables.skill_swap_path = spirit_swap_timer.get_path()

func _physics_process(delta):
	# Handlers for player mechanics and gravity mechanics
	handle_controls(delta)
	handle_gravity(delta)

	# Specific interactions while Bouncy spirit skill is active
	
	if(is_bouncing && is_bouncy): # for the brief bouncing window, we track collision
		movement_velocity.y = -gravity
		var collision: KinematicCollision3D = move_and_collide(movement_velocity * delta)
		if(!collision):
			return
		
		velocity = movement_velocity.bounce(collision.get_normal())
		if(collision.get_normal().y != 0):
			# this is super jank, largely untested but it works for now TODO
			# basically if its not completely vertical switch gravity.
			# some issues i spotted with a nearly horizontal surface, launches correctly but after 
			# a second it kinda stops
			gravity = -gravity * 1.5
		print("collided")
		is_bouncing = false
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
	
	# Basic Movement 

	var input := Vector3.ZERO

	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	# Dash Direction
	
	dashTargetDir = Vector3(input.x * DASH_SPEED,0, input.z * DASH_SPEED);
	
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()

	if input.length() > 1:
		input = input.normalized()

	# Spirit mechanics
	
	if Input.is_action_just_pressed("use_skill"):
		use_skill()
		
	if Input.is_action_just_pressed("switch_spirit"):
		switch_spirit()

	# Movement Passives

	if(is_bouncy):
		handle_bouncy_movement(delta, input)
	else:
		handle_windy_movement(delta, input)
	
	# Jumping

	if Input.is_action_just_pressed("jump"):
		if can_jump:
			jump()
	

func handle_gravity(delta):
	if(is_dashing): #Allows mid-air dash forward
		gravity = 0
		return
	
	gravity += 25 * delta

	if(gravity > 0 and is_on_floor()): 
		can_jump = true
		is_falling = false
		is_bouncing = false
		gravity = 0

func jump():
	gravity = -jump_strength

	if can_jump:
		can_jump = false;
		is_falling = true;

func handle_bouncy_movement(delta, input):
	# Movement while Bouncy spirit is active
	
	if(input.length() <= 0 && movement_velocity.length() > 0): # decel, no input
		movement_velocity = movement_velocity.lerp(Vector3.ZERO, delta * 1)
		
	else:  # accel
		movement_velocity = BOUNCY_ACCEL * input

func handle_windy_movement(delta, input):
	# Movement while Zoomy spirit is active
	
	if(is_dashing):
		movement_velocity = movement_velocity.lerp(dashTargetDir, delta * 10)
	elif(velocity.length() > WINDY_MAX_VEL): # over max windy speed: decel
		movement_velocity = movement_velocity.lerp(Vector3.ZERO, delta * 10)
	elif(input.length() <= 0 && movement_velocity.length() > 0): # decel, no input
		movement_velocity = movement_velocity.lerp(Vector3.ZERO, delta * 50)
	else:
		movement_velocity = WINDY_ACCEL * input

func use_skill():
	#Checks whether Bouncy or Zoomy upon button press
	if(is_bouncy && can_bounce):
		is_bouncing = true
		can_bounce = false
		SignalBus.emit_signal("bounce_cooldown_start", $bounce_cooldown.wait_time)
		$bounce_timer.start()
		$bounce_cooldown.start()
		print("Skill use Bounce")
	elif(!is_bouncy && can_dash):
		is_dashing = true
		can_dash = false
		SignalBus.emit_signal("dash_cooldown_start", $dash_cooldown.wait_time)
		$dash_timer.start()
		$dash_cooldown.start()
		print("Skill use Zoom")
	
func switch_spirit():
	if(can_swap_spirits):
		is_bouncy = !is_bouncy
		can_dash = !can_dash
		can_bounce = !can_bounce
		can_swap_spirits = false
		SignalBus.emit_signal("swap_cooldown_start", $spirit_swap_cooldown.wait_time)
		$spirit_swap_cooldown.start()
		print("Spirit Swap")
		print(is_bouncy)

func _on_dash_timer_timeout() -> void:
	is_dashing = false

func _on_bounce_timer_timeout() -> void:
	is_bouncing = false

func _on_dash_cooldown_timeout() -> void:
	can_dash = true

func _on_bounce_cooldown_timeout() -> void:
	can_bounce = true

func _on_spirit_swap_cooldown_timeout() -> void:
	can_swap_spirits = true
