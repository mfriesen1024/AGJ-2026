extends CharacterBody3D

class Spirit:
	var name: String
	var horizontal_accel: float
	var horizontal_vel: float
	var max_horizontal_vel: float
	var vertical_accel: float
	var max_vertical_vel: float
	
	func _init(name_, hrz_accel_, hrz_vel_, max_hrz_vel_, vrt_accl_, max_vrt_vel_):
		name = name_
		horizontal_accel = hrz_accel_
		horizontal_vel = hrz_vel_	
		max_horizontal_vel = max_hrz_vel_
		vertical_accel = vrt_accl_
		max_vertical_vel = max_vrt_vel_



@export var movement_speed = 250
@export var jump_strength = 10
var gravity = 0
var movement_velocity: Vector3
var rotation_direction: float
var can_jump = true

var cur_spirit_index: int 

var spirits: Array[Spirit]


func _ready():
	var s1 = Spirit.new("Bouncy", 200, 0, 2000, 5, 100)
	var s2 = Spirit.new("Windy", 0, 2, 200, 5, 80)
	spirits.push_back(s1)
	spirits.push_back(s2)
	
	cur_spirit_index = 0




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

	handle_horizontal_vel(delta, input)
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
		
		
		
func handle_horizontal_vel(delta, input, has_max_speed = true): 
	if(spirits[cur_spirit_index].horizontal_vel == 0): return
	movement_velocity = input * spirits[cur_spirit_index].horizontal_vel
	
	
func handle_horizontal_accel(delta, input):
	if(spirits[cur_spirit_index].horizontal_accel == 0): return
	movement_velocity = velocity + (spirits[cur_spirit_index].horizontal_accel * input * delta)
	
	
	
	
func slow_accel(delta):
	pass
		
func handle_vertical_accel(delta, grav_accel):
	pass
	

















func switch_spirit():
	if(cur_spirit_index + 1 >= spirits.size()):
		# out of bounds, loop to start
		cur_spirit_index = 0
	else:
		cur_spirit_index += 1
	print("switched to " + spirits[cur_spirit_index].name)
