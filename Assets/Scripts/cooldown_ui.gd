extends MarginContainer

@onready var animation: AnimationPlayer = $Box/AnimationPlayer
@onready var progBar: TextureProgressBar = $Box/CooldownTimer
@export var animationName = ""
@export var signalName = ""
@export var fillRadial: bool
@export var labelName = ""

@export var targetColour : Color
@export var activatedAnimTime : float = 0.5
@export var activeSignalName = ""


var startColour : Color




func _ready():
	startColour = modulate
	
	SignalBus.connect(signalName, _displayTimer)
	SignalBus.connect(activeSignalName, _displayActive)
	$Box/Label.text = labelName
	if(fillRadial):
		progBar.set_fill_mode(4)
	else:
		progBar.set_fill_mode(0)

func _displayTimer(val):
	modulate = startColour
	animation.play(animationName, -1, 1/val)


func _displayActive(_val):
	modulate = targetColour
	
	
