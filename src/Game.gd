extends Node2D

onready var world = $World
onready var dialog = $UI/EndLevelDialog
onready var level_timer = $UI/LevelTimer
onready var countdown = $UI/Countdown
onready var lives = $UI/Lives
onready var menu = $UI/Menu

func _ready():
    menu.connect("play_game", self, "restart")
    level_timer.connect("time_up", self, "_show_time_up")
    menu.show_intro()
#    restart()
#    dialog.show_game_over()

func restart():
    menu.visible = false
    dialog.visible = false
    Global.total_score = 0
    Global.scores = []
    Global.level_idx = 0
    Global.secret_level_idx = 0
    Global.crm.connect("lives_changed", self, "_lives_changed")
    Global.crm.set_lives(Global.start_lives)
    world.connect("level_complete", self, "_show_dialog")
    world.connect("game_over", self, "_show_game_over")
    dialog.connect("next_level", self, "next_level")
    dialog.connect("restart", self, "restart")
    world.restart()
    countdown.connect("countdown_finished", self, "start_level")
    countdown.start_countdown()

func _lives_changed():
    lives.update_lives()
    if Global.crm.lives < 0:
        _show_game_over()

func _show_dialog(_score):
    Global.game_running = false
    level_timer.stop_time()
    var level_score = level_timer.time
    Global.total_score += level_score
    dialog.show_score(level_score)

func _show_game_over():
    Global.game_running = false
    if Global.crm.lives == null or Global.crm.lives < 0:
        dialog.show_game_over("no_lives")
    else:
        dialog.show_game_over("no_connect")

func _show_time_up():
    Global.game_running = false
    dialog.show_game_over("time_up")

func next_level():
    dialog.visible = false
    Global.secret_level_idx = min(Global.secret_level_idx + 1, len(Global.level_params) - 1)
    Global.level_idx += 1
    world.deferred_next_level()
    countdown.start_countdown()

func start_level():
    level_timer.start_time()
    Global.game_running = true
