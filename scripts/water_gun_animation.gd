extends AnimatedSprite2D
class_name WaterGunAnimation
# Responsabilities
# @respo: animate gun movement


# References
@onready var marker_front: Marker2D = get_node('MarkerFront')
@onready var marker_back: Marker2D = get_node('MarkerBack')
@onready var path: Path2D = get_node("../Path2D")
@onready var path_follow: PathFollow2D = get_node("../Path2D/PathFollow2D")
@onready var path_center: Vector2 = get_node("../Path2D/PathCenter").global_position
@onready var water_tank_anim: AnimatedSprite2D = get_node("WaterTankAnimation")

# Game design parameters
@export_range(0, 1, 0.01) var watergun_movement_speed: float = 0.1
@export var water_tank_tops: Array[float] = []
@export var water_tank_bottoms: Array[float] = []


# Operating variables
@onready var base_scale_x = scale.x


func _ready() -> void:
	# Initial state
	pause()


func set_position_rotation(depth_area: DepthArea, gun_in_gathering_state: bool) -> Vector2:
	# get mouse position, gun direction and mouse direction
	var mouse_position: Vector2 = get_global_mouse_position()
	var gun_direction: Vector2 = marker_front.global_position - marker_back.global_position
	var mouse_direction: Vector2 = mouse_position - marker_back.global_position

	# set watergun position allong it's path
	var mouse_path_center_direction: Vector2 = mouse_position - path_center
	var angle: float = Vector2.UP.angle_to(mouse_path_center_direction)
	var new_progress_ratio: float = 0
	if 0 <= angle:
		scale.x = -base_scale_x
		angle = clamp(angle, 0, PI / 2)
		new_progress_ratio = 0.5 - angle / PI
		if gun_in_gathering_state:
			new_progress_ratio += 2 * angle / PI
	elif angle < 0:
		scale.x = base_scale_x
		angle = clamp(angle, -PI / 2, 0)
		new_progress_ratio = 0.5 - angle / PI
		if gun_in_gathering_state:
			new_progress_ratio += 2 * angle / PI
	path_follow.progress_ratio = lerp(path_follow.progress_ratio, new_progress_ratio, 0.2)
	global_position = path_follow.global_position
	global_position -= (marker_back.global_position - global_position)

	DebugDraw2D.line(path_center, mouse_position)
	DebugDraw2D.line(path_center, path_follow.global_position)

	# set watergun animation frame
	frame = abs(int((path_follow.progress_ratio - 0.5) * 2 * 4))
	animation = 'gun_shoot'
	water_tank_anim.animation = 'gun_shoot'
	if gun_in_gathering_state:
		animation = 'gun_gather'
		water_tank_anim.animation = 'gun_gather'
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


func set_water_tank_display(tank_percentage: float):
	assert(tank_percentage >= 0 and tank_percentage <= 1)
	water_tank_anim.material.set_shader_parameter('percentage', 1 - tank_percentage)
	water_tank_anim.material.set_shader_parameter('top', water_tank_tops[water_tank_anim.frame])
	water_tank_anim.material.set_shader_parameter('bottom', water_tank_bottoms[water_tank_anim.frame])
	
