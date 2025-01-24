extends Node
class_name Main
# Responsabilities
# @respo: start game


# Signals
signal game_speed_up(game_speed_multiplier: float)  #towards window
signal start_game()  #towards window

# References
@onready var debug_score_label: Label = get_node('DebugLabelScore')
@onready var game_over_scene: PackedScene = load("res://scenes/game_over.tscn")
@onready var speech_bubble: Sprite2D = get_node("SpeechBubble")
@onready var start_window: NeighbourWindow = get_node("Background/WindowContainer/window11")

# Game design parameters
@export var initial_game_speed: float = 0.75
@export var game_speed_multiplier: float = 1.1
@export var game_speed_increase_interval: float = 15

# Operating variables
var score: int = 0
var timer: Timer = Timer.new()
var game_started: bool = false


func _ready() -> void:
	# Subscribes to signals
	for window in get_node('Background/WindowContainer').get_children():
		window.window_hit.connect(_on_window_hit)
		
	get_node('WaterGun').water_tank_empty.connect(_on_water_tank_empty)
	
	# Setup
	timer.one_shot = false
	timer.connect("timeout",Callable(self, "_on_speed_up_timer"))
	add_child(timer)

	# Initial state
	timer.wait_time = game_speed_increase_interval
	timer.start()
	start_window.is_window_open = true
	start_window.play("window opening")


func _on_window_hit() -> void:
	# @respo: keep score
	score += 1
	debug_score_label.text = 'Score: ' + str(score)
	if not game_started:
		game_started = true
		start_game.emit()
		speech_bubble.visible = false


func _on_speed_up_timer()->void: 
	# @respo: game rythm
	game_speed_up.emit(game_speed_multiplier)


func _on_water_tank_empty() -> void:
	# @respo: end game
	GameDataSingleton.score = score
	get_tree().change_scene_to_packed(game_over_scene)
