extends Node2D


var n0
var n1
var stops = []  # other Vector2's along the way to connect through
var draw_pool_vector
var current_state # one of harmless, warning, danger

var edge_colors = {
    "harmless": Color("#aaddff"),
    "warning": Color("#dddd44"),
    "danger": Color("#ff0000")
}
var edge_color

onready var collision_area = $CollisionArea
onready var timer = $Timer
onready var zap_sound = $Zap
onready var warning_sound0 = $Warning0
onready var warning_sound1 = $Warning1
onready var warning_sound2 = $Warning2

onready var warning_sounds = [$Warning0, $Warning1, $Warning2]

func set_nodes(_n0, _n1):
    n0 = _n0
    n1 = _n1
    
func set_stops(_stops):
    stops = _stops
#    add_sprite_children()
    update_line_points()

func add_sprite_children():
    for s1 in len(stops) - 1:
        var v1 = stops[s1]
        var v2 = stops[s1 + 1]
        for idx in round(v1.distance_to(v2) / Global.tile_dims.x):
            var bzzt = Sprite.new()
#            bzzt.set_texture()

func create_collision_shapes():
    for idx in (len(stops) - 1):
        var coord0 = stops[idx]
        var coord1 = stops[idx + 1]
        var collision_shape = SegmentShape2D.new()
        collision_shape.set_a(coord0)
        collision_shape.set_b(coord1)
        var collision_node = CollisionShape2D.new()
        collision_node.shape = collision_shape
        collision_area.add_child(collision_node)

func connect_enter_body(body):
    create_collision_shapes()
    collision_area.connect("body_entered", body, "_enter_edge")

func _physics_process(delta):
    if current_state == "danger" or current_state == "warning":
        update_sound_volume()
        
func update_sound_volume():
    var min_dist = INF
    for s in stops:
        var dist = s.distance_squared_to(Global.crm.position)
        if dist < min_dist:
            min_dist = dist
    zap_sound.volume_db = 3 - 0.002 * min_dist
    for warning_sound in warning_sounds:
        warning_sound.volume_db = 3 - 0.002 * min_dist

func _draw():
    draw_polyline(draw_pool_vector, edge_color, false)
        

func get_other_node(node):
    if node == n0:
        return n1
    elif node == n1:
        return n0
    else:
        print("ERROR, asking edge for 'other' from node that is does not have!")

func update_line_points():
    draw_pool_vector = PoolVector2Array(stops)

func set_state(new_state, persistent = true):
    if timer.is_connected("timeout", self, "set_state"):
        timer.disconnect("timeout", self, "set_state")
    current_state = new_state
    edge_color = edge_colors[new_state]
    match new_state:
        "harmless":
            zap_sound.stop()
            if not persistent:
                timer.wait_time = 1.0
                timer.connect("timeout", self, "set_state", ["warning", false])
            set_collision_active(false)
        "warning":
            zap_sound.stop()
            if not persistent:
                timer.wait_time = 0.8
                timer.connect("timeout", self, "set_state", ["danger", false])
            set_collision_active(false)
        "danger":
            zap_sound.play()
            if not persistent:
                timer.wait_time = 1.0 #2.0 + 4.0 * randf()
                timer.connect("timeout", self, "set_state", ["harmless", false])
            set_collision_active(true)
            if Global.crm != null:
                if collision_area.overlaps_body(Global.crm):
                    Global.crm.die()
    if not persistent:
        timer.start()
    update()

func set_collision_active(_active = true):
    collision_area.set_collision_layer_bit(0, _active)
    collision_area.set_collision_mask_bit(0, _active)
