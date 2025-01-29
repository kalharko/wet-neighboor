extends ColorRect
class_name FadeToBlack


# Signals
signal transition_ended()

# References
@onready var game_over_label: Label = get_node("GameOver")
@onready var flavor_text_label: Label = get_node("FlavorText")
@onready var replay_button: Button = get_node("ReplayButton")

# Game design parameters
@export_range(0.0, 1, 0.1) var initial_alpha: float = 0
@export_range(0.0, 1, 0.1) var final_alpha: float = 0.5
@export var transition_speed: float = 0.2

# Operating variables
var transition_complete: bool = false


func _ready() -> void:
    color.a = initial_alpha
    game_over_label.visible = false
    flavor_text_label.visible = false
    replay_button.visible = false
    transition_ended.connect(_on_transition_ended)


func _process(delta: float) -> void:
    # @respo: transition to black
    if transition_complete:
        return

    if initial_alpha > final_alpha:
        if color.a > final_alpha:
            color.a -= delta * transition_speed
        else:
            transition_complete = true
            transition_ended.emit()
    else:
        if color.a < final_alpha:
            color.a += delta * transition_speed
        else:
            transition_complete = true
            transition_ended.emit()
            
func _on_transition_ended() -> void:
    game_over_label.visible = true
    flavor_text_label.visible = true
    replay_button.visible = true
    flavor_text_label.text = "You Annoyed " + str(GameDataSingleton.score) + " neighbours !"
    
