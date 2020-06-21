extends Node2D

signal level_complete(score)
signal game_over

onready var network = $Network
onready var screen_edge = $ScreenEdges
onready var crm = $CRM

func _ready():
    network.connect_signals()
    network.connect("single_network", self, "_show_level_complete")
    network.connect("no_solutions", self, "_show_game_over")
    crm.connect("no_more_lives", self, "_show_game_over")
    
func _show_level_complete():
    Global.game_running = false
    emit_signal('level_complete', 1337) # dummy score

func _show_game_over():
    Global.game_running = false
    emit_signal('game_over')

func _show_no_more_lives():
    Global.game_running = false
    emit_signal('no_more_lives')

func deferred_next_level():
    crm.set_physics_process(false)
    network.set_physics_process(false)
    call_deferred("next_level")

func next_level():
    crm.reset()
    network.generate_new_level()
    network.connect_signals()
#    network.connect("next_level", self, "deferred_next_level")
