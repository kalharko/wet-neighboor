extends Node
class_name Main


# Signals
signal game_speed_up_signal()

# References
@onready var debug_score_label: Label = get_node('DebugLabelScore')

# Game design parameters
@export var initial_game_speed: float = 1
@export var game_speed_up_intervals: float = 5

# Operating variables
var score: int = 0


func _ready() -> void:
	# Subscribes to signals
	for window in get_node('Background/WindowContainer').get_children():
		window.window_hit_signal.connect(_on_window_hit)

	get_node('WaterGun').water_tank_empty_signal.connect(_on_water_tank_empty)


func _on_window_hit() -> void:
	score += 1
	debug_score_label.text = 'Score: ' + str(score)
	

func _on_water_tank_empty() -> void:
	# Game over
	get_tree().quit()
