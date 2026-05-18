extends SpotLight3D

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("adjust_whiteout", _on_adjust_whiteout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_adjust_whiteout(val):
	spot_attenuation = val
