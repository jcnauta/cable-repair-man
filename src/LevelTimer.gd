extends RichTextLabel


var time = 0.0
var stopped = true
var time_str = "[center]%.2f[/center]"

func _ready():
    pass

func _physics_process(delta):
    if not stopped:
        time += delta
        bbcode_text = time_str % time

func start_time():
    stopped = false
    bbcode_text = time_str % time

func stop_time():
    stopped = true
    bbcode_text = time_str % time
    return time

func reset_time():
    time = 0.0
    bbcode_text = time_str % time
