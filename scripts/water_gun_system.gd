extends Node2D

@export var precision: float = 1
var droplet_scene: PackedScene = preload("res://scenes/droplet.tscn")


var areas: Array[DistanceArea] = []
var mouse_area: Area2D
var free_droplets: Array[Sprite2D] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# get mouse area
	mouse_area = get_node("MouseArea")

	# get all Area2D children
	for child in get_node("Distances").get_children():
		if child is DistanceArea:
			areas.append(child)


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

	# if not enough droplets, instantiate one
	if free_droplets.size() == 0:
		var droplet = droplet_scene.instantiate()
		add_child(droplet)
		free_droplets.append(droplet)

	# find a free droplet
	var droplet: Sprite2D = free_droplets.pop_front()
	var bezier_middle_point = marker_front + direction.normalized() * mouse_direction.length()
	droplet.set_course(marker_front, bezier_middle_point, mouse_position, int(mouse_direction.length() / precision))
