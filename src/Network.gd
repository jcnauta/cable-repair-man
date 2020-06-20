extends Node2D

var Grid = preload("res://src/Grid.gd")

onready var nodes = $Nodes
onready var edges = $Edges
onready var crm = $"../CRM"

var grid


func _ready():
    randomize()
    grid = Grid.new()
    grid.place_object(crm)
    generate_nodes()
    create_node_connections()

func generate_nodes():
    for max_nnodes in 40:
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
            print("failed to connect subnets!")

func connect_two_subnets(all_nodes):
    var success = false
    for try in 10:
        # select a random node to start from
        var idx0 = randi() % len(all_nodes)
        var node0 = all_nodes[idx0]
        var neighbors = grid.get_n_nearest(node0.grid_coords)
        for node1 in neighbors:
            if node0.subnet != node1.subnet:
                var edge = grid.create_edge(node0, node1)
                if edge != null:
                    node0.connect_neighbor(node1, edge)
                    edges.add_child(edge)
                    edge.connect_enter_body(crm)
                    success = true
                    break
                else:
                    pass
#                    print("DANGER, edge was null - not implemented")
        if success:
            break
    return success
