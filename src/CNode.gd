extends StaticBody2D

class_name CNode

var subnet_id
var grid_coords
var subnet = []
var edges = []

func _ready():
    subnet.append(self)

func set_grid_coords(coords):
    self.grid_coords = coords
    self.position = Global.tile_dims * grid_coords

func connect_neighbor(new_neighbor, edge):
    check_no_duplicate_edge(edge)
    edges.append(edge)
    new_neighbor.edges.append(edge)
    if subnet != new_neighbor.subnet:
        assimilate_subnet(new_neighbor.subnet)
    else:
        print("Selected node in same subnet!")

func check_no_duplicate_edge(edge):
    var new_neighbor = edge.get_other_node(self)    
    for e in edges:
        var old_neighbor = e.get_other_node(self)
        if old_neighbor == new_neighbor:
            print("ERROR, node is already a neighbor!")
            self.scale = Vector2(1.3, 1.3)

func assimilate_subnet(subnet_to_add):
    subnet += subnet_to_add.duplicate()
    for node in subnet:
        node.set_subnet(subnet)
    update_subnet_color()

func set_subnet(subnet):
    self.subnet = subnet

func update_subnet_color():
    var hash_str = str(subnet).sha1_text().substr(0, 6)
    var hash_color = Color(hash_str)
    for node in subnet:
        node.modulate = hash_color
