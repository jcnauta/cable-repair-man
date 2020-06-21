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

func set_nodes(_n0, _n1):
    n0 = _n0
    n1 = _n1
    
func set_stops(_stops):
    stops = _stops
    update_line_points()

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
            if not persistent:
                timer.wait_time = 1.0
                timer.connect("timeout", self, "set_state", ["warning"])
            set_collision_active(false)
        "warning":
            if not persistent:
                timer.wait_time = 0.8
                timer.connect("timeout", self, "set_state", ["danger"])
            set_collision_active(false)
        "danger":
            if not persistent:
                timer.wait_time = 1.0 #2.0 + 4.0 * randf()
                timer.connect("timeout", self, "set_state", ["harmless"])
            set_collision_active(true)
            if collision_area.overlaps_body(Global.crm):
                Global.crm.die()
    if not persistent:
        timer.start()
    update()

func set_collision_active(_active = true):
    collision_area.set_collision_layer_bit(0, _active)
    collision_area.set_collision_mask_bit(0, _active)
