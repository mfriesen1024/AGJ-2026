extends Node3D

const RAY_LENGTH = 50

@onready var ray: RayCast3D = $ShadowRay
@onready var shadow: Decal = $Shadow

func _ready() -> void:
	ray.add_exception(get_parent_node_3d())
	ray.target_position = Vector3.DOWN * RAY_LENGTH

func _process(_delta):
	if ray.is_colliding():
		var collision_point_global = ray.get_collision_point()
		var collision_point_local = self.to_local(collision_point_global)
		var collision_normal = ray.get_collision_normal()
		
		shadow.position = collision_point_local
		shadow.global_transform = look_at_with_y(shadow.global_transform,collision_normal)
	else:
		shadow.global_transform = look_at_with_y(shadow.global_transform,Vector3.UP)
		
	pass
func look_at_with_y(trnsfrm,new_y):
	trnsfrm.basis.y=new_y
	trnsfrm.basis.x = -trnsfrm.basis.z.cross(new_y)
	trnsfrm.basis = trnsfrm.basis.orthonormalized() 
	return trnsfrm
