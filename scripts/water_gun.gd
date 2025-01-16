extends Node2D
class_name WaterGun


# Signals
signal water_tank_empty_signal()
signal new_droplet_spawned_signal(droplet: Droplet)

# References
@onready var background: Background = get_node("../Background")
@onready var animation: AnimatedSprite2D = get_node("WaterGunAnimation")
@onready var droplet_container: Node = get_node("DropletContainer")
@onready var droplet_scene: PackedScene = preload('res://scenes/droplet.tscn')
@onready var marker_front: Marker2D = get_node('WaterGunAnimation/MarkerFront')

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
enum GunState {SHOOT, GATHER}
var state: GunState = GunState.SHOOT


func _ready() -> void:
	# Subscribes to signals
	get_node('WaterGunAnimation/Area2D').area_entered.connect(_on_area_entered)


func _physics_process(_delta: float) -> void:
	# check state
	state = GunState.SHOOT
	if Input.is_action_pressed("gather"):
		state = GunState.GATHER

	# Set the watergun's position and rotation and get target
	var target: Vector2 = Vector2.ZERO
	var mouse_position: Vector2 = get_global_mouse_position()
	var depth_area: DepthArea = background.get_containing_area(mouse_position)
	target = animation.set_position_rotation(depth_area, state == GunState.GATHER)

	# Shoot
	if state == GunState.SHOOT and Input.is_action_pressed('fire'):
		shoot(target)


func shoot(target: Vector2) -> void:
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
	var mouse_position: Vector2 = get_global_mouse_position()
	droplet.set_course(
		marker_front.global_position,
		target,
		mouse_position
	)	


func _on_droplet_landed(droplet: Droplet) -> void:
	free_droplets.append(droplet)


func _on_area_entered(area: Area2D) -> void:
	if state != GunState.GATHER:
		return
	
	if area.name != 'NeighboorDropletArea':
		return

	area.get_parent().free()
	tank_value += droplet_fill_tank
	tank_value = clamp(tank_value, 0, tank_size)
