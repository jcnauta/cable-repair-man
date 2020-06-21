extends RichTextLabel

signal countdown_finished

onready var countdown_sound= $AudioStreamPlayer

var text_idx = 0
var texts = ["READY", "SET", "CABLE!"]
var tween_alphas = [1.0, 0.0]
var tween
var word_time = 0.7

onready var level_timer = $"../LevelTimer"

func _ready():
    tween = Tween.new()
    add_child(tween)
    tween.connect("tween_completed", self, "_on_tween_completed")

func start_countdown():
    level_timer.reset_time()
    text_idx = 0
    countdown_sound.play()
    _do_countdown()
    
func _do_countdown():
    bbcode_text = "[center]%s[/center]" % texts[text_idx]
    tween.interpolate_property(self, "modulate", \
        Color(1.0, 0.0, 1.0, tween_alphas[0]), Color(1.0, 0.0, 1.0, tween_alphas[1]), word_time, Tween.EASE_IN)
    tween.start()

func _on_tween_completed(object, key):
    text_idx += 1
    if text_idx == len(texts) - 1:
        emit_signal("countdown_finished")
        level_timer.start_time()
    if text_idx < len(texts):
        _do_countdown()

