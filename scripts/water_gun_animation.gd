extends AnimatedSprite2D
class_name WaterGunAnimation

# References
@onready var marker_front: Marker2D = get_node('MarkerFront')
@onready var marker_back: Marker2D = get_node('MarkerBack')
@onready var path: Path2D = get_node("../Path2D")
@onready var path_follow: PathFollow2D = get_node("../Path2D/PathFollow2D")
@onready var path_center: Vector2 = get_node("../Path2D/PathCenter").global_position

# Game design parameters
@export_range(0, 1, 0.01) var watergun_movement_speed: float = 0.1

# Operating variables
@onready var base_scale_x = scale.x


func _ready() -> void:
	# Initial state
	pause()


func set_position_rotation(depth_area: DepthArea) -> Vector2:
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
	elif angle < 0:
		scale.x = base_scale_x
		angle = clamp(angle, -PI / 2, 0)
		new_progress_ratio = 0.5 - angle / PI
	path_follow.progress_ratio = lerp(path_follow.progress_ratio, new_progress_ratio, 0.2)
	global_position = path_follow.global_position

	DebugDraw2D.line(path_center, mouse_position)
	DebugDraw2D.line(path_center, path_follow.global_position)

	# set watergun animation frame
	frame = abs(int((path_follow.progress_ratio - 0.5) * 2 * 4))

	# update gun target depending on the containing area
	var target: Vector2 = marker_back.global_position + mouse_direction / 2
	var gun_target_angle: float = gun_direction.angle_to(mouse_direction)
	if depth_area != null:
		target = marker_back.global_position
		target += mouse_direction.normalized() * gun_direction.length()
		target += (mouse_position - target) * depth_area.water_stream_apex_pos_ratio
		if angle > 0:
			target += mouse_direction.rotated(PI / 2).normalized() * depth_area.water_stream_height_at_apex * -5
		else:
			target += mouse_direction.rotated(PI / 2).normalized() * depth_area.water_stream_height_at_apex * 5
		var target_direction: Vector2 = target - marker_back.global_position
		gun_target_angle = gun_direction.angle_to(target_direction)
	
	# update gun rotation
	rotation += gun_target_angle

	DebugDraw2D.line(
		marker_back.global_position,
		marker_front.global_position,)
	DebugDraw2D.line(
		marker_back.global_position,
		mouse_position,)
	DebugDraw2D.line(
		marker_front.global_position,
		target)
	DebugDraw2D.circle(
		target,
		10)
	if depth_area != null:
		DebugDraw2D.line(
			target,
			target - mouse_direction.rotated(- PI / 2).normalized() * depth_area.water_stream_height_at_apex * 10)

	return target
