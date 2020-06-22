extends StaticBody2D

signal subnet_assimilated

class_name CNode

var grid_coords
var subnet = []
var edges = []

onready var sprite = $AnimatedSprite
onready var highlight = $Highlight

func _ready():
    highlight.set_visible(false)
    subnet.append(self)

func set_grid_coords(coords):
    self.grid_coords = coords
    self.position = Global.grid_coord_to_position(grid_coords)

func connected_to(other_node):
    for e in edges:
        if e.get_other_node(self) == other_node:
            return true
    return false

func connect_neighbor(new_neighbor, edge):
    check_no_duplicate_edge(edge)
    edges.append(edge)
    new_neighbor.edges.append(edge)

func maybe_assimilate_subnet(other_node):
    if subnet != other_node.subnet:
        assimilate_subnet(other_node.subnet)
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
        if is_instance_valid(node):
            node.set_subnet(subnet)
    color_entire_subnet()
    emit_signal("subnet_assimilated")

func set_subnet(subnet):
    self.subnet = subnet

func get_subnet_color():
    return Color(str(subnet).sha1_text().substr(0, 6))

func color_entire_subnet():
    var subnet_color = get_subnet_color()
    for node in subnet:
        if is_instance_valid(node):
            node.sprite.modulate = subnet_color
        
func color_node_by_subnet():
    sprite = get_subnet_color()
    
func set_highlight(now_highlight = true):
    highlight.set_visible(now_highlight)

