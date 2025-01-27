extends Node
class_name Main
# Responsabilities
# @respo: start game


# Signals
signal game_speed_up(game_speed_multiplier: float) # towards window manager
signal start_game() # towards window manager
signal end_game() # towards window manager

# References
@onready var debug_score_label: Label = get_node('DebugLabelScore')
@onready var game_over_scene: PackedScene = load("res://scenes/game_over.tscn")
@onready var speech_bubble: Sprite2D = get_node("SpeechBubble")
@onready var start_window: NeighbourWindow = get_node("Background/WindowManager/window11")
@onready var watergun: WaterGun = get_node('WaterGun')
@onready var neighbour_droplet_container: NeighbourDropletContainer = get_node('Background/NeighbourDropletContainer')
@onready var droplet_container: DropletContainer = get_node('WaterGun/DropletContainer')

# Game design parameters
@export var initial_game_speed: float = 0.75
@export var game_speed_multiplier: float = 1.1
@export var game_speed_increase_interval: float = 15
@export var water_tank_empty_end_game_delay: float = 5

# Operating variables
var score: int = 0
var timer: Timer = Timer.new()
var game_started: bool = false
var end_game_started: bool = false


func _ready() -> void:
	# Subscribes to signals
	for window in get_node('Background/WindowManager').get_children():
		assert(window is NeighbourWindow)
		window.window_hit.connect(_on_window_hit)

	# Setup
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_on_speed_up_timer"))
	add_child(timer)

	# Initial state
	timer.wait_time = game_speed_increase_interval
	timer.start()
	start_window.is_window_open = true
	start_window.play("window opening")


func _physics_process(_delta: float) -> void:
	# @respo: end game
	if watergun.tank_value > 0:
		return
		
	if neighbour_droplet_container.get_nb_in_use() > 0:
		return
	
	if droplet_container.get_nb_in_use() > 0:
		return
	
	if end_game_started:
		return
	end_game_started = true

	GameDataSingleton.score = score
	end_game.emit()

	timer.stop()
	timer.wait_time = water_tank_empty_end_game_delay
	timer.one_shot = true
	timer.disconnect('timeout', Callable(self, "_on_speed_up_timer"))
	timer.connect("timeout", Callable(self, "_on_end_game"))
	timer.start()
	print('start end game')


func _on_window_hit() -> void:
	# @respo: keep score
	score += 1
	debug_score_label.text = 'Score: ' + str(score)
	if not game_started:
		game_started = true
		start_game.emit()
		speech_bubble.visible = false


func _on_speed_up_timer() -> void:
	# @respo: game rythm
	game_speed_up.emit()


func _on_end_game() -> void:
	get_tree().change_scene_to_packed(game_over_scene)
