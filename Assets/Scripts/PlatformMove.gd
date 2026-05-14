extends AnimatableBody3D

var target : Vector3 
var start : Vector3 
var forward : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = $TargetPoint.global_position
	start = global_position
	var tween = get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()
	tween.tween_property(self, "position", target, 2)
	tween.tween_property(self, "position", start, 2)

	

	
		
