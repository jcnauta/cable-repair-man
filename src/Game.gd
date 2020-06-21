extends Node2D

onready var world = $World
onready var win_dialog = $UI/WinDialog
onready var lvl_timer = $UI/LevelTimer
onready var countdown = $UI/Countdown
onready var lives = $UI/Lives

func _ready():
    world.connect("level_complete", self, "_show_win_dialog")
    world.connect("game_over", self, "_show_game_over")
    win_dialog.connect("next_level", self, "next_level")
    win_dialog.connect("redo_level", self, "retry_level")
    countdown.connect("countdown_finished", self, "start_level")
    countdown.start_countdown()
    Global.crm.connect("lives_changed", self, "_lives_changed")
    Global.crm.set_lives(Global.start_lives)

func _lives_changed():
    print("change in game")
    lives.bbcode_text = "Lives: " + str(Global.crm.lives)

func _show_win_dialog(_score):
    lvl_timer.stop_time()
    Global.total_score += lvl_timer.time
    if Global.lvl_idx == Global.last_lvl:
        win_dialog.show_final_score(lvl_timer.time)
    else:
        win_dialog.show_level_score(lvl_timer.time)

func _show_game_over():
    win_dialog.show_game_over()

func retry_level():
    win_dialog.visible = false
    world.next_level()
    countdown.start_countdown()

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
