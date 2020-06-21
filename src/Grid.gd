extends Node

var CNode_scene = preload("res://CNode.tscn")
var Edge_scene = preload("res://Edge.tscn")

class_name Grid

var max_coords = Vector2(30, 18)
var _grid = []

func _init():
    _grid = create_grid()

func create_grid(default_value = null):
    var empty_grid = []
    for c in max_coords.x:
        var current_col = []
        empty_grid.append(current_col)
        for r in max_coords.y:
            current_col.append(default_value)
    return empty_grid

func get_cell(coords):
    if coords.x < 0 or coords.x >= max_coords.x or \
       coords.y < 0 or coords.y >= max_coords.y:
        return null
    return _grid[coords.x][coords.y]

func place_object(obj, coords = null):
    if coords != null:
        if can_place_node(coords):
            _grid[coords.x][coords.y] = obj
            return true
        else:
            return false
    else:
        var max_tries = 20
        var found_place = false
        for try in max_tries:
            coords = Vector2(1 + randi() % int(max_coords.x - 2), 1 + randi() % int(max_coords.y - 2))
            if can_place_node(coords):
                found_place = true
                break
        if found_place:
            _grid[coords.x][coords.y] = obj
            obj.set_grid_coords(coords)
            return true
        else:
            return false

func place_node():
    var coords
    var max_tries = 20
    var found_place = false
    for try in max_tries:
        coords = Vector2(1 + randi() % int(max_coords.x - 2), 1 + randi() % int(max_coords.y - 2))
#        coords = Vector2(randi() % int(max_coords.x), randi() % int(max_coords.y))
        if can_place_node(coords):
            found_place = true
            break
    var new_node
    if found_place:
        new_node = CNode_scene.instance()
        new_node.set_grid_coords(coords)
        _grid[coords.x][coords.y] = new_node
    return new_node

    
func can_place_node(coords):
    var c = coords.x
    var r = coords.y
    if get_cell(Vector2(c, r)) == null and \
       get_cell(Vector2(c-1, r)) == null and \
       get_cell(Vector2(c+1, r)) == null and \
       get_cell(Vector2(c, r-1)) == null and \
       get_cell(Vector2(c, r+1)) == null and \
       get_cell(Vector2(c-1, r-1)) == null and \
       get_cell(Vector2(c-1, r+1)) == null and \
       get_cell(Vector2(c+1, r-1)) == null and \
       get_cell(Vector2(c+1, r+1)) == null:
        return true
    else:
        return false

func get_n_nearest(coords, max_nodes = 6, max_dist = 6):
    var nodes = []
    for dist in range(1, max_dist):
        var new_nodes = nodes_at_distance(coords, dist)
        if len(nodes) + len(new_nodes) <= max_nodes:
            nodes += new_nodes
        else:
            while len(nodes) < max_nodes:
                var rand_idx = randi() % len(new_nodes)
                var new_node = new_nodes[rand_idx]
                new_nodes.remove(rand_idx)
                nodes.append(new_node)
        if len(nodes) == max_nodes:
            break
    return nodes
    
func nodes_at_distance(coords, n):
    var nodes = []
    for dc in range(-n, n + 1):
        for dr in [n - abs(dc), -(n - abs(dc))]:
            var cell = get_cell(coords + Vector2(dc, dr))
            if cell != null and \
               cell is CNode:
                nodes.append(cell)
            if dr == 0: ## column has only candidate
                break
    nodes.shuffle()
    return nodes

func create_edge(n0, n1):
    var path = bfs(n0.grid_coords, n1.grid_coords)
    if path == null:
        return null
    else:
        var edge = Edge_scene.instance()
        edge.set_nodes(n0, n1)
        edge.set_stops(Global.grid_coords_to_positions(path))
        for coord in path:
#            if _grid[coord.x][coord.y] == null: # do not draw over nodes
                _grid[coord.x][coord.y] = edge
        return edge

func bfs(coords0, coords1, max_length = 10):
    var search_grid = create_grid()
    search_grid[coords0.x][coords0.y] = Vector2(0, 0)
    var queue = [coords0]
    while search_grid[coords1.x][coords1.y] == null and \
          not queue.empty():
        var new_queue = []
        for c in queue:
            var new_neighbors = _neighbor_coords(c)
            for new_c in new_neighbors:
                if search_grid[new_c.x][new_c.y] == null:
                    # unvisited
                    if _grid[new_c.x][new_c.y] == null or \
                       new_c == coords1:
                        # not blocked by something
                        search_grid[new_c.x][new_c.y] = c - new_c  # backpointer
                        new_queue.append(new_c)
        queue = new_queue
    if search_grid[coords1.x][coords1.y] == null:
        return null
    else:
        var path = [coords1]
        var current_coords = coords1
        var back_ptr = search_grid[current_coords.x][current_coords.y]
        while back_ptr != Vector2(0, 0):
            current_coords += back_ptr
            back_ptr = search_grid[current_coords.x][current_coords.y]
            path.push_front(current_coords)
        return path

func _neighbor_coords(coords):
    var neighs = []
    if coords.x > 0:
        neighs.append(Vector2(coords.x - 1, coords.y))
    if coords.x < max_coords.x - 1:
        neighs.append(Vector2(coords.x + 1, coords.y))
    if coords.y > 0:
        neighs.append(Vector2(coords.x, coords.y - 1))
    if coords.y < max_coords.y - 1:
        neighs.append(Vector2(coords.x, coords.y + 1))
    return neighs
