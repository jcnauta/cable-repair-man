extends RichTextLabel

signal time_up

onready var beep = $AudioStreamPlayer

var time = 0.0
var stopped = true
var time_str = "[center]%.2f[/center]"
var beep_moment

func _ready():
    pass

func _physics_process(delta):
    if not stopped:
        time = max(0, time - delta)
        if time < beep_moment:
            beep.play()
            beep_moment -= 1
        if time <= 5.0:
            time_str = "[color=red][center]%.2f[/center][/color]"
        else:
            time_str = "[center]%.2f[/center]"
        if time == 0:
            stopped = true
            emit_signal("time_up")
        bbcode_text = time_str % time

func start_time():
    beep_moment = 5.0
    stopped = false
    bbcode_text = time_str % time

func stop_time():
    stopped = true
    bbcode_text = time_str % time
    return time

func reset_time():
    time = Global.time_per_level
    time_str = "[center]%.2f[/center]"
    bbcode_text = time_str % time
