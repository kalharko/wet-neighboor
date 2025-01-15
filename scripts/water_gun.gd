extends Node2D
class_name WaterGun


# Signals
signal water_tank_empty_signal()
signal new_droplet_spawned_signal(droplet: Droplet)

# References
@onready var background: Background = get_node("../Background")
@onready var marker_front: Marker2D = get_node("Animation/MarkerFront")
@onready var marker_back: Marker2D = get_node("Animation/MarkerBack")
@onready var path: Path2D = get_node("Path2D")
@onready var path_follow: PathFollow2D = get_node("Path2D/PathFollow2D")
@onready var path_center: Vector2 = get_node("Path2D/PathCenter").global_position
@onready var animation: AnimatedSprite2D = get_node("Animation")
@onready var droplet_container: Node = get_node("DropletContainer")
@onready var droplet_scene: PackedScene = preload('res://scenes/droplet.tscn')

# Game design parameters
@export_group("Water Tank")
@export var tank_size: int = 100
@export var shot_cost: int = 1

@export_group("Water Stream")
@export var watergun_rotation_speed: float = 1
@export var water_stream_speed: float = 1

@export_group("Water Tank Atlas")
@export var atlas_top_y: int = 90
@export var atlas_bottom_y: int = 480

@export var neighbour_droplet_chance: float = 0.3
@export var droplet_fill_tank = 1

# Operating variables
var free_droplets: Array[Droplet] = []
@onready var tank_value: int = tank_size
@onready var animation_base_scale_x: float = animation.scale.x


func _ready() -> void:
	# Initial state
	animation.pause()
	animation.frame = 3
	animation.animation = "gun_movement_animation"


func _physics_process(delta: float) -> void:
	# get mouse position, gun direction and mouse direction
	var mouse_position: Vector2 = get_global_mouse_position()
	var gun_direction: Vector2 = marker_front.global_position - marker_back.global_position
	var mouse_direction: Vector2 = mouse_position - marker_back.global_position

	# set watergun position allong it's path
	var mouse_path_center_direction: Vector2 = mouse_position - path_center
	var angle: float = Vector2.UP.angle_to(mouse_path_center_direction)
	if 0 <= angle:
		animation.scale.x = -animation_base_scale_x
		angle = clamp(angle, 0, PI / 2)
		path_follow.progress_ratio = 0.5 - angle / PI
	elif angle < 0:
		animation.scale.x = animation_base_scale_x
		angle = clamp(angle, -PI / 2, 0)
		path_follow.progress_ratio = 0.5 - angle / PI
	else:
		path_follow.progress_ratio = 1
	animation.global_position = path_follow.global_position

	DebugDraw2D.line(path_center, mouse_position)
	DebugDraw2D.line(path_center, path_follow.global_position)

	# identify if the mouse is in a DistanceArea
	var containing_area: DepthArea = background.get_containing_area(mouse_position)

	# update gun target depending on the containing area
	var target: Vector2 = marker_back.global_position + mouse_direction / 2
	var gun_target_angle: float = gun_direction.angle_to(mouse_direction)
	if containing_area != null:
		target = marker_back.global_position
		target += mouse_direction.normalized() * gun_direction.length()
		target += (mouse_position - target) * containing_area.water_stream_apex_pos_ratio
		if angle > 0:
			target += mouse_direction.rotated(PI / 2).normalized() * containing_area.water_stream_height_at_apex * -5
		else:
			target += mouse_direction.rotated(PI / 2).normalized() * containing_area.water_stream_height_at_apex * 5
		var target_direction: Vector2 = target - marker_back.global_position
		gun_target_angle = gun_direction.angle_to(target_direction)
	
	# update gun rotation
	gun_target_angle = clampf(
		gun_target_angle,
		-watergun_rotation_speed * delta * watergun_rotation_speed,
		watergun_rotation_speed * delta * watergun_rotation_speed)
	animation.rotation += gun_target_angle

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
	if containing_area != null:
		DebugDraw2D.line(
			target,
			target - mouse_direction.rotated(- PI / 2).normalized() * containing_area.water_stream_height_at_apex * 10)

	# quit if mouse is not down
	if not Input.is_action_pressed("fire"):
		return
	
	# update directions
	gun_direction = marker_front.global_position - marker_back.global_position
	mouse_direction = mouse_position - marker_back.global_position

	# update water tank
	self.tank_value -= shot_cost
	# check if tank is empty
	if self.tank_value <= 0:
		get_tree().quit()

	# if not enough droplets, instantiate one
	if free_droplets.size() == 0:
		var new_droplet = droplet_scene.instantiate()
		new_droplet.droplet_landed_signal.connect(_on_droplet_landed)
		new_droplet_spawned_signal.emit(new_droplet)
		droplet_container.add_child(new_droplet)
		free_droplets.append(new_droplet)

	# find a free droplet
	var droplet: Droplet = free_droplets.pop_front()
	droplet.set_course(
		marker_front.global_position,
		target,
		mouse_position
	)


func _on_droplet_landed(droplet: Droplet) -> void:
	free_droplets.append(droplet)
