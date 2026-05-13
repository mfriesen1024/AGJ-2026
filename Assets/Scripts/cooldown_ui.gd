extends MarginContainer

@onready var animation: AnimationPlayer = $Box/AnimationPlayer
@onready var progBar: TextureProgressBar = $Box/CooldownTimer
@export var animationName = ""
@export var signalName = ""
@export var fillRadial: bool
@export var labelName = ""

func _ready():
	SignalBus.connect(signalName, _displayTimer)
	$Box/Label.text = labelName
	if(fillRadial):
		progBar.set_fill_mode(4)
	else:
		progBar.set_fill_mode(0)

func _displayTimer(val):
	animation.play(animationName, -1, 1/val)
