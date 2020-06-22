extends Node2D

signal single_network
signal no_solutions

var Grid = preload("res://src/Grid.gd")
var EdgeScene = preload("res://Edge.tscn")

onready var nodes = $Nodes
onready var edges = $Edges
onready var place_cable_sound = $PlaceCable
onready var crm = $"../CRM"
onready var spawnpoint = $Spawnpoint

var grid
# two_target_nodes and shadow_edge are used to indicate the next placeable path
var two_target_nodes = [null, null]
var shadow_edge

func _ready():
    randomize()
#    restart()

func restart():
    var generate_level_tries = 0
    while generate_level_tries < 100:
        var success = generate_new_level()
        if success:
            break
        generate_level_tries += 1
    connect_signals()

func _physics_process(delta):
    update_target_nodes()
#    crm_create_edge()

func connect_signals():
    crm.connect("action_0", self, "crm_create_edge")
    for n in nodes.get_children():
        n.connect("subnet_assimilated", self, "check_single_network")

func generate_nodes():
    for max_nnodes in Global.level_params[Global.secret_level_idx]["max_nnodes"]:
        var new_node = grid.place_node()
        if new_node != null:
            nodes.add_child(new_node)

func is_fully_connected(check_paths = false):
    var all_nodes = nodes.get_children()
    var grow_net = []
    var first_node = all_nodes.back()
    for first in first_node.subnet:
        all_nodes.erase(first)
        grow_net.append(first)
    while len(all_nodes) > 0:
        var node_to_add = null
        for n in all_nodes:
            for g in grow_net:
                if n.position.distance_to(g.position) < Global.max_partition_dist:
                    var path =  grid.bfs(n.grid_coords, g.grid_coords)
                    if path != null:
                        node_to_add = n
                        break
                    else:
                        pass
#                        print("no path from " + str(n.grid_coords) + " to " + str(g.grid_coords))
            if node_to_add != null:
                break
        if node_to_add == null:
            return false
        for n in node_to_add.subnet:
            all_nodes.erase(n)
            grow_net.append(n)
    return true

func create_node_connections(subnets = 1):
    var all_nodes = nodes.get_children()
    if len(all_nodes) <= 1:
        return
    var connections_succeeded = 0
    for i in Global.level_params[Global.secret_level_idx]["max_init_connections"]:
        var success = connect_two_subnets(all_nodes)
        if success:
            connections_succeeded += 1
func crm_create_edge():
    if two_target_nodes[0] != null and two_target_nodes[1] != null:
        connect_two_nodes(two_target_nodes[0], two_target_nodes[1], "warning")
        if not is_fully_connected(true):
            emit_signal("no_solutions")
    
func connect_two_nodes(node0, node1, init_edge_state):
    if node0.connected_to(node1):
        return false
    var edge = grid.create_edge(node0, node1)
    if edge != null:
        place_cable_sound.play()
        node0.connect_neighbor(node1, edge)
        edges.add_child(edge)
        edge.connect_enter_body(crm)
        if init_edge_state == null:
            var init_state_var = randf()
            if init_state_var < 0.2:
                init_edge_state = "warning"
            elif init_state_var < 0.5:
                init_edge_state = "danger"
            else:
                init_edge_state = "harmless"
        edge.set_state(init_edge_state, false)
        node0.maybe_assimilate_subnet(node1)
        return true
    else:
        return false

func connect_two_subnets(all_nodes):
    var success = false
    for try in Global.subnet_connect_tries:
        # determine all subnets
        var subnets = []
        for node in all_nodes:
            if not node.subnet in subnets:
                subnets.append(node.subnet)
        var subnets_by_size = []
        for subnet in subnets:
            subnets_by_size.append([len(subnet), subnet])
        subnets_by_size.sort_custom(Util, "sort_by_first")
        subnets = Util.only_second_elements(subnets_by_size)
        # subnets are now sorted
        # pick smallest subnet
#        var source_subnet = subnets[0]

        # pick random subnet
        var use_subnet = false
        var subnet_idx
        var source_subnet
        while true:
            subnet_idx = randi() % len(subnets)
            source_subnet = subnets[subnet_idx]
            if randf() < 1.0 / float(len(source_subnet)):
                break
            
        # pick random node in subnet
        var idx0 = randi() % len(source_subnet)
        var node0 = source_subnet[idx0]
        var neighbors = grid.get_n_nearest(node0.grid_coords)
        for node1 in neighbors:
            if node0.subnet != node1.subnet:
                success = connect_two_nodes(node0, node1, null)
                if success:
                    break
        if success:
            break
    return success

# Select the nearest node that has a node from another subnet to which
# it can connect, together with this other (nearest) node.
func update_target_nodes(only_different_subnets = false):
    # Get nodes in range and sort by distance
    var in_connect_range_with_dist = []
    for node in nodes.get_children():
        var dist = node.position.distance_to(crm.position)
        if dist < Global.connect_range:
            in_connect_range_with_dist.append([dist, node])
    in_connect_range_with_dist.sort_custom(Util, "sort_by_first")
    var in_connect_range = Util.only_second_elements(in_connect_range_with_dist)
    # find nearest node with nearest connectible in different subnet
    var new_targets = [null, null]
    var found_targets = false
    var path_to_new_targets
    for idx0 in len(in_connect_range) - 1:
        var n0 = in_connect_range[idx0]
        for idx1 in range(idx0 + 1, len(in_connect_range)):
            var n1 = in_connect_range[idx1]
            if (only_different_subnets and n0.subnet != n1.subnet) or \
                    (not only_different_subnets and not n0.connected_to(n1)):
                path_to_new_targets = grid.bfs(n0.grid_coords, n1.grid_coords)
                if path_to_new_targets != null:
                    new_targets = [n0, n1]
                found_targets = true
                break
        if found_targets:
            break
    # change highlighting if nearest changed
    if not Util.elements_equal(new_targets, two_target_nodes):
        # remove old highlights
        for t in two_target_nodes:
            if t != null and is_instance_valid(t) and t is CNode:
                t.set_highlight(false)
        two_target_nodes = new_targets
        # set new highlights
        if two_target_nodes[0] != null and two_target_nodes[1] != null:
            for t in two_target_nodes:
                if t != null and is_instance_valid(t) and t is CNode:
                    t.set_highlight(true)
        # remove old shadow path
        if shadow_edge != null:
            shadow_edge.queue_free()
            shadow_edge = null
        if path_to_new_targets != null:
            shadow_edge = EdgeScene.instance()
            add_child(shadow_edge)
            shadow_edge.modulate.a = 0.25
            shadow_edge.set_collision_active(false)
            shadow_edge.set_stops(Global.grid_coords_to_positions(path_to_new_targets))
            shadow_edge.set_state("harmless")

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
    if grid != null:
        grid.queue_free()
    grid = Grid.new()
    grid.place_object(crm)
    spawnpoint.position = crm.position
    generate_nodes()
    if not is_fully_connected():
        return false
    create_node_connections()
    if not is_fully_connected(true):
        return false
    set_physics_process(true)
    crm.set_physics_process(true)
    return true
