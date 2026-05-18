extends CharacterBody3D

# General variables
@export var movement_speed = 250
@export var jump_strength = 10
@onready var walking_sound = $WalkingSound
@onready var animation_player = $Character/Golem_walkcycle/AnimationPlayer
var rng = RandomNumberGenerator.new()
var gravity = 0
var movement_velocity: Vector3
var rotation_direction: float
var can_jump: bool = true
var previously_floored: bool = true
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

func _ready() -> void:
	SignalBus.emit_signal("changed_spirit", is_bouncy)


#func _on_ready():
	#PlayerVariables.skill_swap_path = spirit_swap_timer.get_path()

func _physics_process(delta):
	# Handlers for player mechanics and gravity mechanics
	handle_controls(delta)
	handle_gravity(delta)
	handle_effects(delta)

	# Specific interactions while Bouncy spirit skill is active
	
	if(is_bouncing && is_bouncy): # for the brief bouncing window, we track collision
		movement_velocity.y = -gravity
		var collision: KinematicCollision3D = move_and_collide(movement_velocity * delta)
		if(!collision):
			return
		
		velocity = velocity.bounce(collision.get_normal())
		
		movement_velocity = velocity
		if(collision.get_normal().y != 0):
			gravity = -gravity * 1.5
		print("collided")
		SignalBus.play("res://Assets/Sound/Bounce.ogg")
		is_bouncing = false
		$bounce_timer.stop()
		_on_bounce_timer_timeout()
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
	
	if is_on_floor() and gravity > 2 and !previously_floored:
		SignalBus.play("res://Assets/Sound/LandPixel.wav")

	previously_floored = is_on_floor()

func handle_controls(delta):
	
	# Basic Movement 

	var input := Vector3.ZERO

	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	# Dash Direction
	var curr_vel = Vector2(velocity.z, velocity.x).length()
	
	if curr_vel > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
	dashTargetDir = Vector3.BACK.rotated(Vector3.UP, rotation.y)
	
	if input.length() > 1:
		input = input.normalized()
	
	# Movement Animation
	
	if curr_vel > 0.2 && is_on_floor():
		animation_player.play("Golem/WalkCycle")
	else:
		animation_player.play("Golem/Idle")

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
			SignalBus.play("res://Assets/Sound/JumpPixel.ogg")
	

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

func handle_effects(delta):
	walking_sound.stream_paused = true
	if is_on_floor():
		var horizontal_velocity = Vector2(velocity.x, velocity.z)
		var speed_factor = horizontal_velocity.length() / movement_speed / delta
		if speed_factor > 0.1: # Likely can tweak this value
			walking_sound.stream_paused = false
			walking_sound.pitch_scale = rng.randf_range(0.8,1.1)
			walking_sound.volume_db = -2 - (1/speed_factor)
	if global_position.z < -140:
		SignalBus.emit_signal("adjust_whiteout", global_position.z + 148)

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
		movement_velocity = movement_velocity.lerp(dashTargetDir * DASH_SPEED, delta * 10)
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
		SignalBus.emit_signal("bounce_timer_start", $bounce_timer.wait_time)
		$bounce_timer.start()
		$bounce_cooldown.start()
		print("Skill use Bounce")
	elif(!is_bouncy && can_dash):
		is_dashing = true
		can_dash = false
		SignalBus.emit_signal("dash_cooldown_start", $dash_cooldown.wait_time)
		SignalBus.play("res://Assets/Sound/Dash.wav")
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
		SignalBus.emit_signal("changed_spirit", is_bouncy)
		SignalBus.play("res://Assets/Sound/Droplet.wav")
		$spirit_swap_cooldown.start()
		print("Spirit Swap")
		print(is_bouncy)


func _on_bounce_timer_timeout() -> void:
	SignalBus.emit_signal("bounce_cooldown_start", $bounce_cooldown.wait_time)
	$bounce_cooldown.start()
	is_bouncing = false

func _on_dash_cooldown_timeout() -> void:
	can_dash = true

func _on_bounce_cooldown_timeout() -> void:
	can_bounce = true
	
func _on_dash_timer_timeout() -> void:
	SignalBus.emit_signal("dash_cooldown_start", $dash_cooldown.wait_time)
	$dash_cooldown.start()
	is_dashing = false

func _on_spirit_swap_cooldown_timeout() -> void:
	can_swap_spirits = true
