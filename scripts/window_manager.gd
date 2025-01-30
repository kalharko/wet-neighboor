extends Node2D
class_name WindowManager


# References
@onready var windows: Array[NeighbourWindow] = []

# Game design parameters
@export var max_window_active: int = 6
## initial time between each window activation
@export var update_time: float = 2
## reduction rate of time between each window activation
@export var update_time_reduction_rate: float = 0.9
## minimum time between each window activation
@export var min_update_time: float = 0.5
## maximum delay before window opening
@export var min_window_opening_delay: float = 0.5
@export var max_window_opening_delay: float = 1
## maximum delay before window closing
@export var min_window_closing_delay: float = 3
@export var max_window_closing_delay: float = 5
## reduction rate of delay between window opening and closing
@export_range(0.7, 1, 0.001) var window_delay_reduction_rate: float = 0.95

# Operating variables
var rnd: RandomNumberGenerator = RandomNumberGenerator.new()
var timer: Timer = Timer.new()


func _ready() -> void:
    # References
    for child in get_children():
        assert(child is NeighbourWindow)
        windows.append(child)
    
    # Subscribe to signals
    get_node("/root/Main").game_speed_up.connect(_on_game_speed_up)
    get_node("/root/Main").start_game.connect(_on_game_start)
    get_node("/root/Main").end_game.connect(_on_end_game)

    # Initial state
    rnd.randomize()
    timer.one_shot = false
    timer.connect("timeout", Callable(self, "_on_time_timeout"))
    add_child(timer, false, Node.INTERNAL_MODE_BACK)
    timer.wait_time = update_time


func _on_time_timeout() -> void:
    # @respo: activate/deactivate windows
    var inactive_windows: Array[NeighbourWindow] = []
    for window in windows:
        if not window.is_active:
            inactive_windows.append(window)

    # quit if enough windows are active
    if len(windows) - len(inactive_windows) >= max_window_active:
        return
    
    # activate a random inactive window
    var window_to_activate: NeighbourWindow = inactive_windows[rnd.randi_range(0, len(inactive_windows) - 1)]
    window_to_activate.activate(
        rnd.randf_range(min_window_opening_delay, max_window_opening_delay),
        rnd.randf_range(min_window_closing_delay, max_window_closing_delay)
    )


func _on_game_start() -> void:
    timer.start()


func _on_end_game() -> void:
    timer.stop()
    for window in windows:
        window.start_end_game_sequence(
            rnd.randf_range(0, max_window_closing_delay) / 2
        )


func _on_game_speed_up() -> void:
    timer.wait_time = max(min_update_time, timer.wait_time * update_time_reduction_rate)
    print('on game speed up: ' + str(timer.wait_time))
