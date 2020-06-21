extends KinematicBody2D

signal action_0

var grid_coords
var spawn_position
var speed = 250.0
var dead = false
var two_near_nodes = []
var dummy_move = Vector2(0.0, 0.0) # to trigger collision

onready var sprite = $Sprite

func _ready():
    Global.crm = self

func _physics_process(delta):
    if dead or not Global.game_running:
        return
    if Input.is_action_pressed("ui_left"):
        if Input.is_action_pressed("ui_up"):
            rotation = -0.25 * PI
        elif Input.is_action_pressed("ui_down"):
            rotation = -0.75 * PI
        else:
            rotation = -0.5 * PI
    if Input.is_action_pressed("ui_right"):
        if Input.is_action_pressed("ui_up"):
            rotation = 0.25 * PI
        elif Input.is_action_pressed("ui_down"):
            rotation = 0.75 * PI
        else:
            rotation = 0.5 * PI
    if not (Input.is_action_pressed("ui_left") or \
            Input.is_action_pressed("ui_right")):
        if Input.is_action_pressed("ui_up"):
            rotation = 0.0
        if Input.is_action_pressed("ui_down"):
            rotation = PI
    if Input.is_action_pressed("ui_left") or \
       Input.is_action_pressed("ui_up") or \
       Input.is_action_pressed("ui_down") or \
       Input.is_action_pressed("ui_right"):
        move_and_slide_diagonal_fix()
    else:
        move_and_slide(dummy_move)
    if Input.is_action_just_pressed("action_0"):
        emit_signal("action_0")

func set_grid_coords(coords):
    grid_coords = coords
    self.position = Global.grid_coord_to_position(grid_coords, true)
    spawn_position = self.position

func move_and_slide_diagonal_fix():
    var move_dir = Vector2(0, -1).rotated(rotation)
    move_and_slide(speed * move_dir)

func set_two_nearest_nodes(nodes):
    for old in two_near_nodes:
        old.set_highlight(false)
    if nodes != two_near_nodes:
        two_near_nodes = nodes
        for n in nodes:
            pass

func _enter_edge(body):
    if body == self:
        die()

func die():
    dead = true
    sprite.play("die")
    sprite.connect("animation_finished", self, "anim_finished", [])

func anim_finished():
    if sprite.animation == "die":
        respawn()
        sprite.play("default")

func respawn():
    dead = false
    position = spawn_position

func reset():
    for con in get_signal_connection_list('action_0'):
        con.source.disconnect('action_0', con.target, con.method)
    dead = false
    two_near_nodes = []
    grid_coords = null
    spawn_position = null
    sprite.play("default")
