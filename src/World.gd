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

func restart():
    crm.reset() # order matters
    network.restart() # order matters

func _show_level_complete():
    emit_signal('level_complete', 1337) # dummy score

func _show_game_over():
    emit_signal('game_over')

func _show_no_more_lives():
    emit_signal('no_more_lives')

func deferred_next_level():
    crm.set_physics_process(false)
    network.set_physics_process(false)
    call_deferred("next_level")

func next_level():
    crm.reset()
    var generate_level_tries = 0
    while generate_level_tries < 100:
        var success = network.generate_new_level()
        if success:
            break
        generate_level_tries += 1
    network.connect_signals()
#    network.connect("next_level", self, "deferred_next_level")
