extends Node

# Signals

signal active_spirit(val)
signal swap_cooldown_start(val)
signal dash_cooldown_start(val)
signal bounce_cooldown_start(val)
signal bounce_timer_start(val)
signal dash_timer_start(val)
signal changed_spirit(val: bool)
signal adjust_whiteout(val)

var num_streams = 8
var bus = "sfx"

var available = []  # The available streams to use
var queue = []  # The queue of sounds to play


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in num_streams:
		var p = AudioStreamPlayer.new()
		add_child(p)
		
		available.append(p)
		
		p.volume_db = -10
		p.finished.connect(_on_stream_finished.bind(p))
		p.bus = bus

func _on_stream_finished(stream): available.append(stream)

func play(sound_path): queue.append(sound_path)

func _process(_delta):
	if not queue.is_empty() and not available.is_empty():
		
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available[0].pitch_scale = randf_range(0.9, 1.1)
		
		available.pop_front()
