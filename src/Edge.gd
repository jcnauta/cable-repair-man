extends Node2D

var n0
var n1
var stops = []  # other Vector2's along the way to connect through
var draw_pool_vector

onready var collision_area = $CollisionArea

func set_nodes(_n0, _n1):
    n0 = _n0
    n1 = _n1
    
func set_stops(stops):
    self.stops = stops
    update_line_points()

func create_collision_shapes():
    for idx in (len(stops) - 1):
        var coord0 = stops[idx]
        var coord1 = stops[idx + 1]
#        var collision_obj = ConvexPolygonShape2D.new()
        var collision_shape = SegmentShape2D.new()
        collision_shape.set_a(coord0)
        collision_shape.set_b(coord1)
        var collision_node = CollisionShape2D.new()
        collision_node.shape = collision_shape
        collision_area.add_child(collision_node)

func connect_enter_body(body):
    create_collision_shapes()
    collision_area.connect("body_entered", body, "enter_edge")

func _draw():
    draw_polyline(draw_pool_vector, Color(255, 0, 0), false)

func get_other_node(node):
    if node == n0:
        return n1
    elif node == n1:
        return n0
    else:
        print("ERROR, asking edge for 'other' from node that is does not have!")

func update_line_points():
    draw_pool_vector = PoolVector2Array(stops)
