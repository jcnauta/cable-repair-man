extends Control

signal play_game

onready var tbn = $TitleBodyNext
onready var tc = $TitleChoices

onready var body = $TitleBodyNext/Body
onready var next = $TitleBodyNext/Next
onready var choices = $TitleChoices/Choices
var title

func _ready():
#    show_intro()
    pass

func show_intro():
    set_process_input(true)
    self.visible = true
    tc.visible = false
    tbn.visible = true
    title = tbn.get_node("Title")
    title.bbcode_text = "Cable Repair Man"
    body.clear()
    body.push_mono()
    body.append_bbcode("""In the near future, humanity's unbridled hunger for bandwidth causes the global networks to overload. The internet has become a fragmented place and information no longer travels freely. Megacorporations have consolidated their grip on the remaining subnets, and there are few who remember what net neutrality was.
    
But when all hope seems lost, a hero rises to unite the internet once more. It's Cable Repair Man.""")
    next.clear()
    next.push_mono()
    next.append_bbcode("[center]Press ENTER to continue...[/center]")
    set_process_input(true)

func show_main_menu():
    self.visible = true
    tbn.visible = false
    tc.visible = true
    title = tc.get_node("Title")
    title.bbcode_text = "[center]Menu[/center]"
    tc.set_choices(["Play", "Highscores", "Options"])

func _input(e):
    if tbn.visible:
        if e.is_action_pressed("ui_accept"):
            show_main_menu()
    elif tc.visible:
        if e.is_action_pressed("ui_accept"):
            var the_choice = tc.get_current_choice()
            if the_choice == "Play":
                set_process_input(false)
                emit_signal("play_game")
            elif the_choice == "Highscores":
                pass
            elif the_choice == "Options":
                pass
            else:
                print("Warning: invalid choice " + str(the_choice))
        if e.is_action_pressed("ui_down"):
            print("still printing!")
            tc.next_choice()
        if e.is_action_pressed("ui_up"):
            tc.prev_choice()
