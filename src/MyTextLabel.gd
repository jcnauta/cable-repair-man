extends RichTextLabel

class_name MyTextLabel

var my_font
export var font_size = 8 setget set_font_size

func _init():
    rect_min_size = Vector2(100, 25)
    bbcode_enabled = true
    my_font = DynamicFont.new()
    my_font.font_data = load("res://fonts/Minecraftia-Regular.ttf")
    add_font_override("normal_font", my_font)
    add_font_override("mono_font", my_font)
    add_color_override("default_color", Color.black)

func set_font_size(new_size):
    print("setget triggered")
    my_font.size = new_size
