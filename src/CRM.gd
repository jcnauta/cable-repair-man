extends KinematicBody2D

class_name CRM

signal action_0
signal no_more_lives
signal lives_changed

var lives
var grid_coords
var spawn_position
var speed = 180.0
var dead = false
var two_near_nodes = []
var move_angle = 0
var dummy_move = Vector2(0.0, 0.0) # to trigger collision

onready var sprite = $Sprite
onready var footsteps = $Footsteps
onready var die_sound = $Die


func _ready():
    Global.crm = self

func _physics_process(delta):
    if not Global.game_running:
        sprite.play("idle")
        footsteps.stop()
    if dead or not Global.game_running:
        return
    if Input.is_action_pressed("ui_left"):
        sprite.scale.x = 1
        if Input.is_action_pressed("ui_up"):
            move_angle = -0.25 * PI
            sprite.play("run_nw")
        elif Input.is_action_pressed("ui_down"):
            sprite.play("run_sw")
            move_angle = -0.75 * PI
        else:
            sprite.play("run_w")
            move_angle = -0.5 * PI
    if Input.is_action_pressed("ui_right"):
        sprite.scale.x = -1
        if Input.is_action_pressed("ui_up"):
            sprite.play("run_nw")
            move_angle = 0.25 * PI
        elif Input.is_action_pressed("ui_down"):
            sprite.play("run_sw")
            move_angle = 0.75 * PI
        else:
            sprite.play("run_w")
            move_angle = 0.5 * PI
    if not (Input.is_action_pressed("ui_left") or \
            Input.is_action_pressed("ui_right")):
        if Input.is_action_pressed("ui_up"):
            sprite.play("run_n")
            move_angle = 0.0
        if Input.is_action_pressed("ui_down"):
            sprite.play("run_s")
            move_angle = PI
    if Input.is_action_pressed("ui_left") or \
       Input.is_action_pressed("ui_up") or \
       Input.is_action_pressed("ui_down") or \
       Input.is_action_pressed("ui_right"):
        move_and_slide_diagonal_fix()
        if not footsteps.playing:
            footsteps.play()
    else:
        footsteps.stop()
        sprite.play("idle")
        move_and_slide(dummy_move)
    if Input.is_action_just_pressed("action_0"):
        emit_signal("action_0")

func set_grid_coords(coords):
    grid_coords = coords
    self.position = Global.grid_coord_to_position(grid_coords, true)
    spawn_position = self.position

func move_and_slide_diagonal_fix():
    var move_dir = Vector2(0, -1).rotated(move_angle)
    move_and_slide(speed * move_dir)

func set_two_nearest_nodes(nodes):
    for old in two_near_nodes:
        old.set_highlight(false)
    if nodes != two_near_nodes:
        two_near_nodes = nodes
        for n in nodes:
            pass

func _enter_edge(body):
    if body == self and Global.game_running:
        print("enter edge!")
        die()

func die():
    dead = true
    die_sound.play()
    sprite.play("die")
    set_lives(lives - 1)
    sprite.connect("animation_finished", self, "anim_finished", [])

func anim_finished():
    if sprite.animation == "die":
        respawn()

func respawn():
    dead = false
    position = spawn_position
    sprite.play("idle")
    footsteps.stop()

func reset():
    for con in get_signal_connection_list('action_0'):
        con.source.disconnect('action_0', con.target, con.method)
    lives = Global.start_lives
    dead = false
    two_near_nodes = []
    grid_coords = null
    spawn_position = null
    sprite.play("idle")
    footsteps.stop()

func update_animation_speed():
    for anim in sprite.frames.get_animation_names():
        sprite.frames.set_animation_speed(anim, floor(speed / 10.0))

func set_lives(new_lives):
    lives = new_lives
    emit_signal("lives_changed")
    if lives < 0:
        print("lives: " + str(lives))
        emit_signal("no_more_lives")
