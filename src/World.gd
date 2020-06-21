extends Node2D

signal level_complete(time)

onready var network = $Network
onready var screen_edge = $ScreenEdges
onready var crm = $CRM

func _ready():
    network.connect_signals()
    network.connect("single_network", self, "_show_level_complete")
    
func _show_level_complete():
    Global.game_running = false
    emit_signal('level_complete', 14.38)

func deferred_next_level():
    crm.set_physics_process(false)
    network.set_physics_process(false)
    call_deferred("next_level")

func next_level():
    crm.reset()
    network.generate_new_level()
    network.connect_signals()
#    network.connect("next_level", self, "deferred_next_level")
