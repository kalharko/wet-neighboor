extends Node
class_name Main
# Responsabilities
# @respo: start/end game
# @respo: keep score
# @respo: game rythm


# Signals
signal game_speed_up_signal() #towards window
#signal start_game_signal()    #towards window


# References
@onready var debug_score_label: Label = get_node('DebugLabelScore')

# Game design parameters
@export var initial_game_speed: float = 1
@export var game_speed_multiplier: float = 1.0
# Operating variables
var score: int = 0


func _ready() -> void:
	# Subscribes to signals
	for window in get_node('Background/WindowContainer').get_children():
		window.window_hit_signal.connect(_on_window_hit)
		self.game_speed_up_signal.connect(window._on_game_speed_up)

	get_node('WaterGun').water_tank_empty_signal.connect(_on_water_tank_empty)


func _on_window_hit() -> void:
	score += 1
	debug_score_label.text = 'Score: ' + str(score)

func _on_speed_up_timer()->void: 
	game_speed_multiplier += 0.1
	game_speed_up_signal.emit()

func _on_water_tank_empty() -> void:
	# Game over
	get_tree().quit()
