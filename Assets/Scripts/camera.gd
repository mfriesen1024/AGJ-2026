extends Node3D

@export var target: Node3D
@export var offset: Vector3 = Vector3(0, 0, 0) 

@onready var camera = $Camera

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not target:
		return
	
	self.position = self.position.lerp(target.position, delta * 10)
	
	camera.position = camera.position.lerp(Vector3(0, 0, 6), 10 * delta)
