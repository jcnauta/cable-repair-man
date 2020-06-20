extends KinematicBody2D

var grid_coords
var spawn_position
var speed = 150.0
var dead = false

onready var sprite = $Sprite

func set_grid_coords(coords):
    grid_coords = coords
    self.position = Global.grid_coord_to_position(grid_coords, true)
    spawn_position = self.position

func _physics_process(delta):
    if dead:
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
        
func move_and_slide_diagonal_fix():
    var move_dir = Vector2(0, -1).rotated(rotation)
    move_and_slide(speed * move_dir)

func enter_edge(body):
    if body == self:
        print("dying")
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
