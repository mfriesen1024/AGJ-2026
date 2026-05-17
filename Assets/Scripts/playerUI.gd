extends Node

var swapButton :CanvasItem
var dashButton :CanvasItem
var bounceButton :CanvasItem

@export var dashActiveSignalName = ""
@export var bounceActiveSignalName = ""
@export var swapSignalName = ""

@export var bouncyUIColour : Color
@export var windyUIColour : Color

@export var inactiveAlpha = 0.8

var isBouncy : bool = true

# Called when the node enters the scene tree for the first time.

func _enter_tree() -> void:
	SignalBus.connect("changed_spirit", _swap_spirit_display)
	swapButton = $SkillSwap
	dashButton = $Dash
	bounceButton = $Bounce
	


func _swap_spirit_display(val : bool) -> void:
	var colourTween = get_tree().create_tween()
	var sizeTween = get_tree().create_tween()
	if(val):
		colourTween.tween_property(swapButton, "modulate", bouncyUIColour, 0.2)
		
		var inactiveButtonColour :Color = dashButton.modulate
		inactiveButtonColour.a = inactiveAlpha
		sizeTween.tween_property(dashButton, "modulate", inactiveButtonColour, 0.2)
		var activeButtonColour :Color = bounceButton.modulate
		activeButtonColour.a = 1
		sizeTween.parallel().tween_property(bounceButton, "modulate", activeButtonColour, 0.2)
		
	else:
		colourTween.tween_property(swapButton, "modulate", windyUIColour, 0.2)
	
		var inactiveButtonColour :Color = bounceButton.modulate
		inactiveButtonColour.a = inactiveAlpha
		sizeTween.tween_property(bounceButton, "modulate", inactiveButtonColour, 0.2)
		var activeButtonColour :Color = dashButton.modulate
		activeButtonColour.a = 1
		sizeTween.parallel().tween_property(dashButton, "modulate", activeButtonColour, 0.2)
