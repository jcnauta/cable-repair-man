extends Node2D

signal single_network

var Grid = preload("res://src/Grid.gd")

onready var nodes = $Nodes
onready var edges = $Edges
onready var crm = $"../CRM"

var grid
var two_target_nodes = [null, null]

func _ready():
    randomize()
    grid = Grid.new()
    grid.place_object(crm)
    generate_nodes()
    create_node_connections()

func _physics_process(delta):
    update_target_nodes()

func connect_signals():
    crm.connect("action_0", self, "crm_create_edge")
    for n in nodes.get_children():
        n.connect("subnet_assimilated", self, "check_single_network")

func generate_nodes():
    for max_nnodes in 5:
        var new_node = grid.place_node()
        if new_node != null:
            nodes.add_child(new_node)

func create_node_connections(subnets = 1):
    var all_nodes = nodes.get_children()
    if len(all_nodes) <= 1:
        return
    for i in 30:
        var success = connect_two_subnets(all_nodes)
        if not success:
#            print("failed to connect subnets!")
            pass

func crm_create_edge():
    connect_two_nodes(two_target_nodes[0], two_target_nodes[1], "harmless")
    
func connect_two_nodes(node0, node1, init_edge_state = "danger"):
    if node0.connected_to(node1):
        return false
    var edge = grid.create_edge(node0, node1)
    if edge != null:
        node0.connect_neighbor(node1, edge)
        edges.add_child(edge)
        edge.connect_enter_body(crm)
        edge.set_state(init_edge_state)
        node0.maybe_assimilate_subnet(node1)
        return true
    else:
        return false

func connect_two_subnets(all_nodes):
    var success = false
    for try in 10:
        # select a random node to start from
        var idx0 = randi() % len(all_nodes)
        var node0 = all_nodes[idx0]
        var neighbors = grid.get_n_nearest(node0.grid_coords)
        for node1 in neighbors:
            if node0.subnet != node1.subnet:
                success = connect_two_nodes(node0, node1)
                if success:
                    break
        if success:
            break
    return success

func update_target_nodes():
    var nearest_dist = INF
    var near_dist = INF
    var new_targets = [null, null] # closest first, second-closest second
    for node in nodes.get_children():
        var dist = node.position.distance_to(crm.position)
        if dist < nearest_dist:
            near_dist = nearest_dist
            nearest_dist = dist
            new_targets.push_front(node)
        elif dist < near_dist:
            near_dist = dist
            new_targets[1] = node
        if len(new_targets) == 3:
            new_targets.pop_back()
    var nearest_changed = false
    for t in two_target_nodes:
        var same = false
        for n in new_targets:
            if t == n:
                same = true
                break
        if not same:
            nearest_changed = true
            break
    if nearest_changed:
        for t in two_target_nodes:
            if t != null and is_instance_valid(t):
                t.set_highlight(false)
        two_target_nodes = new_targets
        for t in two_target_nodes:
            if t != null and is_instance_valid(t):
                t.set_highlight(true)

func check_single_network():  # win if there is only a single subnet
    var the_subnet
    for n in nodes.get_children():
        if the_subnet == null:
            the_subnet = n.subnet
        else:
            if the_subnet != n.subnet:
                return false
    
    emit_signal("single_network")
    return true

func generate_new_level():
    set_physics_process(false)
    crm.set_physics_process(false)
    for e in edges.get_children():
        e.free()
    for n in nodes.get_children():
        n.free()
    grid.queue_free()
    grid = Grid.new()
    grid.place_object(crm)
    generate_nodes()
    create_node_connections()
    set_physics_process(true)
    crm.set_physics_process(true)
