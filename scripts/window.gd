extends AnimatedSprite2D
class_name NeighbourWindow
# Responsabilities
# @respo: open/close
# @respo: spawn NeighbourDroplet
# @respo: get hit
# @respo: increase score


# Signals
signal window_hit() # towards main

# References
@onready var window_area: Area2D = get_node("Area2D")
@onready var neighbour_droplet_container: NeighbourDropletContainer = get_node('/root/Main/Background/NeighbourDropletContainer')
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../../../AudioContainer/voices/AudioStreamPlayer2D"
@onready var open_window_sound: AudioStreamPlayer2D = $"../../../AudioContainer/sfx/open window sound"
@onready var close_window_sound: AudioStreamPlayer2D = $"../../../AudioContainer/sfx/close window sound"

# Game design parameters
@export var is_start_window: bool = false
@export var droplet_spawn_probability: float = 0.6
@export var neighbour_droplet_target: Vector2 = Vector2(450, 610)
@export var time_out_after_being_active: float = 5

# Operating variables
var is_window_open: bool = false
var timer: Timer = Timer.new()
var is_active: bool = false
var time_before_closing: float = 1
var in_end_game_sequence: bool = false
var recently_closed: bool = false


func _ready() -> void:
    # Subscribes to signals
    get_node('/root/Main/WaterGun/DropletContainer').new_droplet_spawned.connect(_on_new_droplet_spawned)

    # Setup
    timer.one_shot = true
    timer.connect("timeout", Callable(self, "_on_timer_timeout"))
    add_child(timer, false, Node.INTERNAL_MODE_BACK)


func open_window() -> void:
    open_window_sound.play()
    is_window_open = true
    self.play("window opening")
    timer.wait_time = time_before_closing
    timer.start()


func close_window() -> void:
    close_window_sound.play()
    is_window_open = false
    recently_closed = true
    self.play("window closing")
    timer.wait_time = time_out_after_being_active
    timer.start()


func activate(opening_delay: float, closing_delay: float) -> void:
    print('opening_delay :' + str(opening_delay) + ' closing_delay: ' + str(closing_delay))
    is_active = true
    time_before_closing = closing_delay
    timer.wait_time = opening_delay
    timer.start()


func start_end_game_sequence(opening_delay: float) -> void:
    timer.stop()
    in_end_game_sequence = true
    if not is_window_open:
        timer.wait_time = opening_delay
        timer.start()
        timer.disconnect('timeout', Callable(self, '_on_timer_timeout'))
        timer.connect("timeout", Callable(self, "_on_end_game_sequence"))


func _on_end_game_sequence() -> void:
    is_window_open = true
    play('window opening')
    

func _on_timer_timeout() -> void:
    if is_window_open:
        close_window()
    elif recently_closed:
        is_active = false
        recently_closed = false
    else:
        open_window()


func _spawn_droplet() -> void:
    var new_droplet: NeighbourDroplet = neighbour_droplet_container.get_droplet()
    var middle_pos: Vector2 = Vector2(
        position.x + (neighbour_droplet_target.x - position.x) / 2,
        position.y - (neighbour_droplet_target.y - position.y) / 2
    )
    new_droplet.set_course(
        position,
        middle_pos,
        neighbour_droplet_target
        )


func _on_new_droplet_spawned(droplet: Droplet) -> void:
    droplet.droplet_landed.connect(_on_droplet_landed)


func _on_droplet_landed(droplet: Droplet) -> void:
    if in_end_game_sequence:
        return

    if not is_window_open:
        return
    
    if not window_area.overlaps_area(droplet.droplet_area):
        return
    is_window_open = false
    audio_stream_player_2d.play()
    close_window()
    window_hit.emit()
    
    if rng.randf() <= droplet_spawn_probability:
        _spawn_droplet()
