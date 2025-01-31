extends Sprite2D
class_name NeighbourDroplet


# Signals
signal neighbour_droplet_landed(droplet: NeighbourDroplet)

# References

# Game design parameters
@export var travel_time: float = 0.25
@export var bezier_length_computation_precision: float = 0.01
## The droplet size is multiplied by a value going from 1 -> end_of_travel_size_multiplication during it's travel time
@export_range(0.0, 1, 0.01) var end_of_travel_size_multiplication: float = 2.3
@export var is_tuto_bottle: bool = false

# Operating variables
var is_collected: bool = false
var screen_height: int = int(ProjectSettings.get_setting("display/window/size/viewport_height"))
var nb_step: int = 0
var current_step: int = 0
var curve_start: Vector2
var curve_middle: Vector2
var curve_end: Vector2
@onready var initial_size: Vector2 = scale


func _physics_process(_delta: float) -> void:
    # @respo: moving
    # @respo: land
    if current_step >= nb_step:
        return

    current_step += 1
    if current_step >= nb_step:
        land()
        return
    
    # set position along bezier curve
    var t: float = float(self.current_step) / float(self.nb_step)
    t = t * t
    var new_pos: Vector2 = _quadratic_bezier(
        self.curve_start,
        self.curve_middle,
        self.curve_end,
        t
    )
    self.global_position = new_pos

    # set rotation
    self.rotation += deg_to_rad(360.0 * _delta)

    # set size
    scale = initial_size * (end_of_travel_size_multiplication + (1 - end_of_travel_size_multiplication) * (1 - t))


func set_course(start: Vector2, middle: Vector2, end: Vector2) -> void:
    position = start
    current_step = 0
    visible = true
    nb_step = int(self._quadratic_bezier_length(start, middle, end) * travel_time)

    curve_start = start
    curve_middle = middle
    curve_end = end


func land() -> void:
    if is_tuto_bottle:
        self.queue_free()
        return

    visible = false
    neighbour_droplet_landed.emit(self)
    global_position = Vector2(-10, -10)
    current_step = nb_step
    

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
    var q0 = p0.lerp(p1, t)
    var q1 = p1.lerp(p2, t)

    var r = q0.lerp(q1, t)
    return r


func _quadratic_bezier_normal(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
    return p0 * (2 * t - 2) + (2 * p2 - 4 * p1) * t + 2 * p1


func _quadratic_bezier_length(p0: Vector2, p1: Vector2, p2: Vector2):
    var precision: float = bezier_length_computation_precision
    var length: float = 0
    var current_point: Vector2
    var previous_point: Vector2 = _quadratic_bezier(p0, p1, p2, 0)
    var step: float = precision
    while step <= 1:
        current_point = _quadratic_bezier(p0, p1, p2, step)
        length += previous_point.distance_to(current_point)
        previous_point = current_point
        step += precision
    return length
