extends Node2D
class_name TutoBottleSpawner


# References
@onready var neighbour_droplet_scene: PackedScene = preload("res://scenes/neighbour_droplet.tscn")

# Game design parameter
@export var spawn_interval: float = 4
@export var neighbour_droplet_travel_time_override: float = 0.5

# Operating variable
var timer: Timer = Timer.new()


func start_water_bottle_spawn() -> void:
    print('start_water_bottle_spawn')
    timer.wait_time = spawn_interval
    timer.one_shot = false
    timer.connect("timeout", Callable(self, "_on_timer_timeout"))
    add_child(timer)
    timer.start()
    _on_timer_timeout()
    
    
func stop_water_bottle_spawn() -> void:
    timer.stop()


func _on_timer_timeout() -> void:
    # @respo: spawn neighbour droplets on a timer
    var bottle: NeighbourDroplet = neighbour_droplet_scene.instantiate()
    add_child(bottle)
    bottle.travel_time = neighbour_droplet_travel_time_override
    #bottle.z_index = 100
    var middle_position: Vector2 = Vector2(
        global_position.x + (450 - global_position.x) / 2,
        global_position.y - (610 - global_position.y) / 2
    )
    bottle.set_course(
        global_position,
        middle_position,
        Vector2(450, 610))
    #bottle.set_course(
        #Vector2(100, 100),
        #Vector2(150, 150),
        #Vector2(200, 200)
    #)
    bottle.is_tuto_bottle = true
    
