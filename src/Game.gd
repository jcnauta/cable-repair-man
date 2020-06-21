extends Node2D

onready var world = $World
onready var win_dialog = $UI/WinDialog
onready var lvl_timer = $UI/LevelTimer
onready var countdown = $UI/Countdown

func _ready():
    world.connect("level_complete", self, "_show_win_dialog")
    win_dialog.connect("next_level", self, "next_level")
    countdown.connect("countdown_finished", self, "start_level")
    countdown.start_countdown()

func _show_win_dialog(_score):
    lvl_timer.stop_time()
    Global.total_score += lvl_timer.time
    if Global.lvl_idx == Global.last_lvl:
        win_dialog.show_final_score()
    else:
        win_dialog.show_level_score(lvl_timer.time)

func next_level():
    win_dialog.visible = false
    if Global.lvl_idx == Global.last_lvl:
        Global.total_score = 0
        Global.lvl_idx = 0
        world.next_level()
    else:
        Global.lvl_idx += 1
        world.next_level()
    countdown.start_countdown()

func start_level():
    Global.game_running = true
