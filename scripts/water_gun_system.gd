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

# Game design parameters
@export_group("Water Tank")
@export var tank_size: int = 100
@export var shot_cost: int = 1

@export_group("Water Stream")
@export var precision: float = 1
var droplet_scene: PackedScene = preload("res://scenes/droplet.tscn")

@export_group("Water Tank Atlas")
@export var atlas_top_y: int = 90
@export var atlas_bottom_y: int = 480

# Operating variables
var free_droplets: Array[Droplet] = []
var water_tank_atlas_texture: AtlasTexture = AtlasTexture.new()
@onready var texture_size: Vector2 = water_tank.texture.get_size()
@onready var tank_value: int = tank_size


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get references
	for child in get_node("Distances").get_children():
		if child is DistanceArea:
			areas.append(child)

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


func _physics_process(_delta: float) -> void:
	# get mouse position, gun direction and mouse direction
	var mouse_position: Vector2 = get_global_mouse_position()
	var direction: Vector2 = marker_front.global_position - marker_back.global_position
	var mouse_direction: Vector2 = mouse_position - marker_back.global_position

	# get angle between gun direction and mouse direction
	var angle: float = direction.angle_to(mouse_direction)

	# identify if the mouse is in a DistanceArea
	mouse_area.position = mouse_position
	for area in areas:
		if area.overlaps_area(mouse_area):
			# if so add the DistanceArea's value to angle
			angle += area.distance
			break
	
	# rotate gun
	var water_gun = get_node("WaterGun")
	water_gun.rotation += angle

	# quit if mouse is not down
	if not Input.is_action_pressed("fire"):
		return
	
	# update MarkerFront and MarkerBack
	direction = marker_front.global_position - marker_back.global_position
	# get mouse direction
	mouse_direction = mouse_position - marker_back.global_position

	# update water tank
	self.tank_value -= shot_cost
	# check if tank is empty
	if self.tank_value <= 0:
		get_tree().quit()

	# update water tank visual
	var region = Rect2(
		0,
		atlas_top_y + (atlas_bottom_y - atlas_top_y) * (1 - float(tank_value) / float(tank_size)),
		texture_size.x,
		texture_size.y - atlas_top_y - (atlas_bottom_y - atlas_top_y) * (1 - float(tank_value) / float(tank_size))
	)
	water_tank_atlas_texture.region = Rect2(region)
	water_tank.texture = water_tank_atlas_texture
	water_tank.position.y = water_tank_atlas_texture.region.position.y / 2

	# if not enough droplets, instantiate one
	if free_droplets.size() == 0:
		var new_droplet = droplet_scene.instantiate()
		add_child(new_droplet)
		free_droplets.append(new_droplet)

	# find a free droplet
	var droplet: Droplet = free_droplets.pop_front()
	var bezier_middle_point = marker_front.global_position + direction.normalized() * mouse_direction.length() * 0.75
	droplet.set_course(marker_front.global_position, bezier_middle_point, mouse_position, int(mouse_direction.length() / precision))


func free_droplet(droplet: Droplet) -> void:
	free_droplets.append(droplet)
	droplet_landed.emit(droplet)
