extends Node

var tile_dims = Vector2(16, 15)
var crm
var game_running = false
var total_score = 0.0
var lvl_idx = 0
var last_lvl = 2

func grid_coord_to_position(coord, pos_on_tile_center = true):
    var pos = coord * tile_dims
    if pos_on_tile_center:
        pos += 0.5 * tile_dims
    return pos

func grid_coords_to_positions(coord_array, pos_on_tile_center = true):
    var pos_array = []
    for c in coord_array:
        pos_array.append(grid_coord_to_position(c, pos_on_tile_center))
    return pos_array
