extends Node2D

class_name WaterGunSystem

signal water_gun_shot_signal(droplet: Droplet)

@export var tank_size: int = 100
@onready var tank_value: int = tank_size
@export var shot_cost: int = 1
@export var precision: float = 1
var droplet_scene: PackedScene = preload("res://scenes/droplet.tscn")


var areas: Array[DistanceArea] = []
var mouse_area: Area2D
var free_droplets: Array[Droplet] = []

@onready var water_tank = get_node("WaterGun/WaterTank")
var water_tank_atlas_texture: AtlasTexture
@export var atlas_top_y: int = 90
@export var atlas_bottom_y: int = 480
var texture_size: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# get mouse area
	mouse_area = get_node("MouseArea")

	# get all Area2D children
	for child in get_node("Distances").get_children():
		if child is DistanceArea:
			areas.append(child)

	# setup atlas
	water_tank_atlas_texture = AtlasTexture.new()
	water_tank_atlas_texture.atlas = water_tank.texture
	texture_size = water_tank.texture.get_size()
	water_tank_atlas_texture.region = Rect2(
		0,
		atlas_top_y,
		texture_size.x,
		texture_size.y - atlas_top_y)
	water_tank.texture = water_tank_atlas_texture
	water_tank.position.y = water_tank_atlas_texture.region.position.y / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	# get mouse position
	var mouse_position = get_global_mouse_position()
	# get position of children MarkerFront and MarkerBack
	var marker_front = get_node("WaterGun/MarkerFront").get_global_position()
	var marker_back = get_node("WaterGun/MarkerBack").get_global_position()

	# get gun direction
	var direction = marker_front - marker_back
	
	# get mouse direction
	var mouse_direction = mouse_position - marker_back

	# get angle between gun direction and mouse direction
	var angle = direction.angle_to(mouse_direction)

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
	
	# additionnal rotation bias for bezier curve
	water_gun.rotation += PI / 12
	
	# update MarkerFront and MarkerBack
	marker_front = get_node("WaterGun/MarkerFront").get_global_position()
	marker_back = get_node("WaterGun/MarkerBack").get_global_position()
	direction = marker_front - marker_back
	# get mouse direction
	mouse_direction = mouse_position - marker_back

	# quit if mouse is not down
	if not Input.is_action_pressed("fire"):
		return

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
		var droplet = droplet_scene.instantiate()
		add_child(droplet)
		free_droplets.append(droplet)

	# find a free droplet
	var droplet: Droplet = free_droplets.pop_front()
	var bezier_middle_point = marker_front + direction.normalized() * mouse_direction.length()
	droplet.set_course(marker_front, bezier_middle_point, mouse_position, int(mouse_direction.length() / precision))


func free_droplet(droplet: Droplet) -> void:
	free_droplets.append(droplet)
	water_gun_shot_signal.emit(droplet)
