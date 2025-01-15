extends Node2D
class_name WaterGunSystem


# Signals
signal droplet_landed(droplet: Droplet)

# References
@onready var areas: Array[Node] = []
@onready var mouse_area: Area2D = get_node("MouseArea")
@onready var marker_front: Marker2D = get_node("WaterGun/MarkerFront")
@onready var marker_back: Marker2D = get_node("WaterGun/MarkerBack")
@onready var water_tank = get_node("WaterGun/WaterTank")
@onready var water_gun = get_node("WaterGun")
@onready var water_gun_opened = get_node("WaterGun/WaterGunOpened")
@onready var droplet_scene: PackedScene = preload("res://scenes/droplet.tscn")

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
var neighbour_droplets: Array[NeighbourDroplet] = []
var water_tank_atlas_texture: AtlasTexture = AtlasTexture.new()

var is_collect_mode: bool = false

@onready var texture_size: Vector2 = water_tank.texture.get_size()
@onready var tank_value: int = tank_size


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get references
	for child in get_node("Distances").get_children():
		if child is DistanceArea:
			areas.append(child)

	get_node('WaterGun/WaterGunOpened/Area2D').area_entered.connect(_on_water_tank_collision)
	water_gun_opened.visible = false
	
	# Initial state
	water_tank_atlas_texture.atlas = water_tank.texture
	water_tank_atlas_texture.region = Rect2(
		0,
		atlas_top_y,
		texture_size.x,
		texture_size.y - atlas_top_y)
	water_tank.texture = water_tank_atlas_texture
	water_tank.position.y = water_tank_atlas_texture.region.position.y / 2


func _process(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	if is_collect_mode:
		return 
	# get mouse position, gun direction and mouse direction
	var mouse_position: Vector2 = get_global_mouse_position()
	var gun_direction: Vector2 = marker_front.global_position - marker_back.global_position
	var mouse_direction: Vector2 = mouse_position - marker_back.global_position

	# identify if the mouse is in a DistanceArea
	mouse_area.position = mouse_position
	var containing_area: DistanceArea = null
	for area in areas:
		if area.overlaps_area(mouse_area):
			containing_area = area
			break

	# update gun target depending on the containing area
	var target: Vector2 = marker_back.global_position + mouse_direction / 2
	var gun_target_angle: float = gun_direction.angle_to(mouse_direction)
	if containing_area != null:
		target = marker_back.global_position
		target += mouse_direction.normalized() * gun_direction.length()
		target += (mouse_position - target) * containing_area.water_stream_high_point_ratio
		target += mouse_direction.rotated(PI / 2).normalized() * containing_area.additional_height * 10
		var target_direction: Vector2 = target - marker_back.global_position
		gun_target_angle = gun_direction.angle_to(target_direction)
	
	# update gun rotation
	gun_target_angle = clampf(
		gun_target_angle,
		-watergun_rotation_speed * delta * watergun_rotation_speed,
		watergun_rotation_speed * delta * watergun_rotation_speed)
	water_gun.rotation += gun_target_angle

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
			target - mouse_direction.rotated(- PI / 2).normalized() * containing_area.additional_height * 10)
	

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
	
	_update_water_tank_visual()

	# if not enough droplets, instantiate one
	if free_droplets.size() == 0:
		var new_droplet = droplet_scene.instantiate()
		add_child(new_droplet)
		free_droplets.append(new_droplet)

	# find a free droplet
	var droplet: Droplet = free_droplets.pop_front()
	droplet.set_course(
		marker_front.global_position,
		target,
		mouse_position
	)
	

func free_droplet(droplet: Droplet) -> void:
	free_droplets.append(droplet)
	droplet_landed.emit(droplet)

#toggling water gun mode
func _input(event: InputEvent)->void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		toggle_mode()

func toggle_mode() -> void:
	is_collect_mode = !is_collect_mode
	if is_collect_mode:
		print("collect mode")
		water_gun.self_modulate = Color(1, 1, 1, 0) # Zero opacity
		water_gun_opened.visible = true
	else:
		print("shoot mode")
		water_gun.self_modulate = Color(1, 1, 1, 0) # Zero opacity
		water_gun_opened.visible = false

func _on_water_tank_collision(area: Area2D)->void: 
	if is_collect_mode == false: 
		return
	if area.get_parent().name == "Droplet":
		print(area.get_parent().name)
		tank_value += droplet_fill_tank
		print(tank_value)
		if tank_value> tank_size:
			tank_value = tank_size
	_update_water_tank_visual()

func _update_water_tank_visual()->void: 
	
	#fill the tank
	var region = Rect2(
		0,
		atlas_top_y + (atlas_bottom_y - atlas_top_y) * (1 - float(tank_value) / float(tank_size)),
		texture_size.x,
		texture_size.y - atlas_top_y - (atlas_bottom_y - atlas_top_y) * (1 - float(tank_value) / float(tank_size))
	)
	water_tank_atlas_texture.region = Rect2(region)
	water_tank.texture = water_tank_atlas_texture
	water_tank.position.y = water_tank_atlas_texture.region.position.y / 2
	


	
