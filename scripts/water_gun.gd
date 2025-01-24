extends Node2D
class_name WaterGun
# Responsabilities
# @respo: shoot
# @respo: switch mode
# @respo: gather
# @respo: record tank


# Signals
signal water_tank_empty() #towards main

# References
@onready var background: Background = get_node("../Background")
@onready var animation: AnimatedSprite2D = get_node("WaterGunAnimation")
@onready var droplet_container: DropletContainer = get_node("DropletContainer")
@onready var droplet_scene: PackedScene = preload('res://scenes/droplet.tscn')
@onready var marker_front: Marker2D = get_node('WaterGunAnimation/MarkerFront')
@onready var debug_label_tank: Label = get_node('/root/Main/DebugLabelTank')

# Game design parameters
@export_group("Water Tank")
@export var tank_size: int = 100
@export var shot_cost: int = 1
@export var mode_switch_animation_time: float = 1
@export var droplet_fill_tank = 6

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
	var depth_area: DepthArea = background.get_background_depth_area(mouse_position)
	target = animation.set_position_rotation(depth_area, state == GunState.GATHER)
	
	# Set the watergun's tank level
	animation.set_water_tank_display(float(tank_value) / tank_size)

	# Shoot
	if state == GunState.SHOOT and Input.is_action_pressed('fire'):
		shoot(target, depth_area.additional_height_at_stream_apex)


func shoot(target: Vector2, additional_travel_time: float) -> void:
	# update water tank
	self.tank_value -= shot_cost
	debug_label_tank.text = 'Tank: ' + str(tank_value)
	# check if tank is empty
	if self.tank_value <= 0:
		water_tank_empty.emit()
		return

	# find a free droplet
	var droplet: Droplet = droplet_container.get_droplet()
	var mouse_position: Vector2 = get_global_mouse_position()
	droplet.set_course(
		marker_front.global_position,
		target,
		mouse_position,
		additional_travel_time / 500
	)	

func _on_area_entered(area: Area2D) -> void:
	if state != GunState.GATHER:
		return
	
	if area.name != 'NeighboorDropletArea':
		return

	area.get_parent().free()
	tank_value += droplet_fill_tank
	tank_value = clamp(tank_value, 0, tank_size)

	debug_label_tank.text = 'Tank: ' + str(tank_value)
