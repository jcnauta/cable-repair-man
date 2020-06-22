extends Node

# Font Minecraftia by AndrewTyler.net

var tile_dims = Vector2(16, 16)
var crm
var game_running = false
var total_score = 0.0
var level_idx = 0
var secret_level_idx = 0
var connect_range = 80.0
var max_partition_dist = 2 * connect_range - 20.0
var subnet_connect_tries = 30
var start_lives = 2
var time_per_level = 20.0
var scores = [
#        {
#            "level": 3,
#            "time": 4.21
#        }
   ]  # keep all scores, also to save as highscore
var screen_dims = Vector2(480, 288)

var level_params = [
#    {
#        "max_nnodes": 5,
#        "max_init_connections": 3,
#        "harmless_duration": 3.0,
#        "zap_duration": 1.0
#    },
    {
        "max_nnodes": 10,
        "max_init_connections": 6,
        "harmless_duration": 3.0,
        "zap_duration": 1.0
    },
    {
        "max_nnodes": 15,
        "max_init_connections": 12,
        "harmless_duration": 2.5,
        "zap_duration": 1.2
    },
    {
        "max_nnodes": 20,
        "max_init_connections": 15,
        "harmless_duration": 2.2,
        "zap_duration": 1.4
    },
    {
        "max_nnodes": 25,
        "max_init_connections": 16,
        "harmless_duration": 1.8,
        "zap_duration": 1.5
    },
    {
        "max_nnodes": 30,
        "max_init_connections": 20,
        "harmless_duration": 1.6,
        "zap_duration": 1.6
    },
    {
        "max_nnodes": 33,
        "max_init_connections": 21,
        "harmless_duration": 1.5,
        "zap_duration": 1.6
    },
    {
        "max_nnodes": 35,
        "max_init_connections": 23,
        "harmless_duration": 1.6,
        "zap_duration": 1.6
    },
    {
        "max_nnodes": 38,
        "max_init_connections": 26,
        "harmless_duration": 1.6,
        "zap_duration": 1.6
    },
    {
        "max_nnodes": 40,
        "max_init_connections": 26,
        "harmless_duration": 1.5,
        "zap_duration": 1.6
    },
]

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

# save the current scores as a highscore
func save_highscore():
    var last_level = len(scores)
    var total_time = 0.0
    for s in scores:
        total_time += s.time
    var score_obj = {
        "level": last_level,
        "time": total_time
       }
    var highscore_file = File.new()
    highscore_file.open("user://highscores.save", File.WRITE)
    highscore_file.store_line(to_json(score_obj))
    highscore_file.close()

func load_highscores():
    var highscore_file = File.new()
    if not highscore_file.file_exists("user://highscores.save"):
        return null
    highscore_file.open("user://highscores.save", File.READ)
    var all_highscores = []
    while not highscore_file.eof_reached():
        var current_line = parse_json(highscore_file.get_line())
        if current_line != null:
            all_highscores.append(current_line)    
    return all_highscores
