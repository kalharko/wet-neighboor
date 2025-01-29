extends AnimatedSprite2D
class_name WaterGunAnimation


# References
@onready var marker_front: Marker2D = get_node('MarkerFront')
@onready var marker_back: Marker2D = get_node('MarkerBack')
@onready var shooting_path: Path2D = get_node("../ShootingPath")
@onready var shooting_path_follow: PathFollow2D = get_node("../ShootingPath/PathFollow2D")
@onready var path_center: Vector2 = get_node("../ShootingPath/PathCenter").global_position
@onready var water_tank_anim: AnimatedSprite2D = get_node("WaterTankAnimation")

# Game design parameters
@export_range(0, 1, 0.01) var shooting_movement_speed: float = 0.1
@export var water_tank_tops: Array[float] = []
@export var water_tank_bottoms: Array[float] = []
@export var gathering_position_y: float = 565
@export var gathering_movement_speed: float = 0.09
@export var gathering_rotation_speed: float = 0.08
@export var position_animation_frame_curve: Curve = Curve.new()


# Operating variables
@onready var base_scale_x = scale.x


func _ready() -> void:
    # Initial state
    pause()


func set_shooting_position_rotation(depth_area: DepthArea) -> Vector2:
    # @respo: animate watergun shooting
    # get mouse position, gun direction and mouse direction
    var mouse_position: Vector2 = get_global_mouse_position()
    var gun_direction: Vector2 = marker_front.global_position - marker_back.global_position
    var mouse_direction: Vector2 = mouse_position - marker_back.global_position

    # set watergun position allong it's shooting_path
    var mouse_path_center_direction: Vector2 = mouse_position - path_center
    var angle: float = Vector2.UP.angle_to(mouse_path_center_direction)
    var new_progress_ratio: float = 0
    if 0 <= angle:
        scale.x = -base_scale_x
        angle = clamp(angle, 0, PI / 2)
        new_progress_ratio = 0.5 - angle / PI
    elif angle < 0:
        scale.x = base_scale_x
        angle = clamp(angle, -PI / 2, 0)
        new_progress_ratio = 0.5 - angle / PI
    shooting_path_follow.progress_ratio = lerp(shooting_path_follow.progress_ratio, new_progress_ratio, shooting_movement_speed)
    global_position = shooting_path_follow.global_position
    global_position -= (marker_back.global_position - global_position)
        

    # set watergun animation frame
    frame = position_animation_frame_curve.sample(abs(shooting_path_follow.progress_ratio - 0.5) * 2) * 8
    animation = 'gun_shoot'
    water_tank_anim.animation = 'gun_shoot'
    water_tank_anim.frame = frame

    # update gun target depending on the containing area
    var target: Vector2 = marker_back.global_position + mouse_direction / 2
    var gun_target_angle: float = gun_direction.angle_to(mouse_direction)
    if depth_area != null:
        target = marker_back.global_position
        target += mouse_direction.normalized() * gun_direction.length()
        target += (mouse_position - target) * depth_area.stream_apex_position_ration
        if angle > 0:
            target += mouse_direction.rotated(PI / 2).normalized() * depth_area.additional_height_at_stream_apex * -5
        else:
            target += mouse_direction.rotated(PI / 2).normalized() * depth_area.additional_height_at_stream_apex * 5
        var target_direction: Vector2 = target - marker_back.global_position
        gun_target_angle = gun_direction.angle_to(target_direction)
    
    # update gun rotation
    rotation += gun_target_angle

    return target


func set_gathering_position_rotation() -> void:
    # @respo: animate watergun gathering
    var mouse_position: Vector2 = get_global_mouse_position()

    # set position
    global_position = Vector2(
        lerp(global_position.x, mouse_position.x, gathering_movement_speed),
        lerp(global_position.y, gathering_position_y, gathering_movement_speed)
    )

    # set rotation
    rotation = lerp_angle(rotation, 0, gathering_rotation_speed)

    # set animation
    animation = 'gun_gather'
    frame = 0
    water_tank_anim.animation = 'gun_gather'
    water_tank_anim.frame = 0


func set_water_tank_display(tank_percentage: float):
    # @respo: animate water tank
    assert(tank_percentage >= 0 and tank_percentage <= 1)
    water_tank_anim.material.set_shader_parameter('percentage', 1 - tank_percentage)
    if water_tank_anim.animation == "gun_shoot":
        water_tank_anim.material.set_shader_parameter('top', water_tank_tops[water_tank_anim.frame])
        water_tank_anim.material.set_shader_parameter('bottom', water_tank_bottoms[water_tank_anim.frame])
    else:
        water_tank_anim.material.set_shader_parameter('top', water_tank_tops[len(water_tank_tops) -1])
        water_tank_anim.material.set_shader_parameter('bottom', water_tank_bottoms[len(water_tank_bottoms) -1])
