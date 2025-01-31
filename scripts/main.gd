extends Node
class_name Main
# Responsabilities
# @respo: start game


# Signals
signal game_speed_up(game_speed_multiplier: float) # towards window manager
signal title_screen_exited()
signal start_game() # towards window manager
signal end_game() # towards window manager

# References
@onready var debug_score_label: Label = get_node('DebugLabelScore')
@onready var watergun: WaterGun = get_node('WaterGun')
@onready var neighbour_droplet_container: NeighbourDropletContainer = get_node('Background/NeighbourDropletContainer')
@onready var droplet_container: DropletContainer = get_node('WaterGun/DropletContainer')
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

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
var still_on_title_screen: bool = true


func _ready() -> void:
    # Subscribes to signals
    for window in get_node('Background/WindowManager').get_children():
        assert(window is NeighbourWindow)
        window.window_hit.connect(_on_window_hit)

    # Setup
    timer.one_shot = false
    timer.connect("timeout", Callable(self, "_on_speed_up_timer"))
    add_child(timer)
    if not GameDataSingleton.is_first_game:
        animation_player.play('setup_replay')


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


func _input(event: InputEvent) -> void:
    if event.is_action_pressed('fire') and GameDataSingleton.is_first_game:
        if still_on_title_screen:
            still_on_title_screen = false
            animation_player.play('animate_title_screen')


func _on_window_hit() -> void:
    # @respo: keep score
    score += 1
    debug_score_label.text = 'Score: ' + str(score)


func start_tuto() -> void:
    if GameDataSingleton.is_first_game:
        print('Start Tuto')
        animation_player.play('hide_title_screen')
        animation_player.queue('tuto_sequence_1')
    else:
        set_start_game()


func set_start_game() -> void:
    if GameDataSingleton.is_first_game:
        animation_player.play('start_game')
        GameDataSingleton.is_first_game = false
    game_started = true
    timer.wait_time = game_speed_increase_interval
    timer.start()
    start_game.emit()


func notify_title_screen_exited() -> void:
    title_screen_exited.emit()


func _on_speed_up_timer() -> void:
    # @respo: game rythm
    game_speed_up.emit()


func _on_end_game() -> void:
    animation_player.play('game_over')
