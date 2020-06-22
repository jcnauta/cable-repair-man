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
    tc.set_choices(["Play", "How to Play"])
    var scores = Global.load_highscores()
    var highest = []
    var highest_level = 0
    for score in scores:
#        var score = score_array[0]
        if score.level == highest_level:
            highest.append(score)
        elif score.level > highest_level:
            highest_level = score.level
            highest = [score]
    var time = INF
    for h in highest:
        if h.time < time:
            time = h.time
    tc.show_highscore(highest_level, time)

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
            elif the_choice == "How to Play":
                tc.visible = false
                tbn.visible = true
                title = tbn.get_node("Title")
                title.set_bbcode("How to Play")
                body.set_bbcode("Arrow keys to move, 'A' to connect two nodes (if you are close enough to the nodes). Your objective in each level is to connect all nodes within 20 seconds while losing at most 2 lives. What's the highest level you can reach, in the least time possible?")
                next.set_bbcode("Press ENTER to Return")
            else:
                print("Warning: invalid choice " + str(the_choice))
        if e.is_action_pressed("ui_down"):
            tc.next_choice()
        if e.is_action_pressed("ui_up"):
            tc.prev_choice()
