extends Node
class_name Main
# Responsabilities
# @respo: start/end game
# @respo: keep score
# @respo: game rythm


# Signals
signal game_speed_up(game_speed_multiplier: float) #towards window
signal start_game()    #towards window


# References
@onready var debug_score_label: Label = get_node('DebugLabelScore')

# Game design parameters
@export var initial_game_speed: float = 1
@export var game_speed_multiplier: float = 1.1
@export var game_speed_increase_interval: float = 10

# Operating variables
var score: int = 0
var timer: Timer = Timer.new()


func _ready() -> void:
	# Subscribes to signals
	for window in get_node('Background/WindowContainer').get_children():
		window.window_hit.connect(_on_window_hit)
		
	get_node('WaterGun').water_tank_empty.connect(_on_water_tank_empty)
	
	# Setup
	timer.one_shot = true
	timer.connect("timeout",Callable(self, "_on_speed_up_timer"))
	add_child(timer)

	# Initial state
	timer.wait_time = game_speed_increase_interval
	timer.start()


func _on_window_hit() -> void:
	score += 1
	debug_score_label.text = 'Score: ' + str(score)

func _on_speed_up_timer()->void: 
	game_speed_up.emit(game_speed_multiplier)
	timer.start()
	print("ergerq")

func _on_water_tank_empty() -> void:
	# Game over
	get_tree().quit()
