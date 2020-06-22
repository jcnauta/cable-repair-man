extends VBoxContainer


onready var choices = $Choices
onready var bleep = $AudioStreamPlayer

var choice_idx = 0
var choice_list = []
var choice_children


func set_choices(names):
    choice_children = choices.get_children()
    for c in choice_children:
        c.queue_free()
    choice_list.clear()
    for name in names:
        choice_list.append(name)
        var choice_label = RichTextLabel.new()
        choices.add_child(choice_label)
        choice_label.rect_min_size = Vector2(100, 25)
        choice_label.bbcode_enabled = true
#        choice_label.get("custom_fonts/normal_font")
        var new_font = DynamicFont.new()
        new_font.font_data = load("res://fonts/Minecraftia-Regular.ttf")
        choice_label.add_font_override("normal_font", new_font)
        choice_label.add_color_override("default_color", Color.black)
        choice_label.bbcode_text = "[center]" + name + "[/center]"

    choice_children = choices.get_children()
    choice_idx = 0
    update_highlighting()
    
func next_choice():
    if choice_idx == len(choice_children) - 1:
        return
    else:
        choice_idx += 1
        update_highlighting()
        print("next choice")
        bleep.play()
    
func prev_choice():
    if choice_idx == 0:
        return
    else:
        choice_idx -= 1
        update_highlighting()
        print("prev choice")
        bleep.play()

func update_highlighting():
    for idx in len(choice_children):
        var label = choice_children[idx]
        if idx == choice_idx:
            label.add_color_override("default_color", Color("#ff00ff"))
        else:
            label.add_color_override("default_color", Color.black)
        
func get_current_choice():
    return choice_list[choice_idx]
