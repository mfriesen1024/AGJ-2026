extends Node

# Signals

signal active_spirit(val)
signal swap_cooldown_start(val)
signal dash_cooldown_start(val)
signal bounce_cooldown_start(val)
signal bounce_timer_start(val)
signal dash_timer_start(val)
signal changed_spirit(val: bool)

# Called when the node enters the scene tree for the first time.
func _ready():
	print(ready)
