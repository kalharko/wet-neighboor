extends Node2D
class_name WaterGun


# References
@onready var background: Background = get_node("../Background")
@onready var animation: AnimatedSprite2D = get_node("WaterGunAnimation")
@onready var droplet_container: DropletContainer = get_node("DropletContainer")
@onready var droplet_scene: PackedScene = preload('res://scenes/droplet.tscn')
@onready var marker_front: Marker2D = get_node('WaterGunAnimation/MarkerFront')
@onready var marker_back: Marker2D = get_node('WaterGunAnimation/MarkerBack')
@onready var debug_label_tank: Label = get_node('/root/Main/DebugLabelTank')
@onready var droplet_collected: AudioStreamPlayer2D = $"../AudioContainer/sfx/droplet_collected"
@onready var water_splash: AudioStreamPlayer2D = $"../AudioContainer/sfx/water splash"

# Game design parameters
@export_group("Water Tank")
@export var tank_size: int = 100
@export var shot_cost: int = 1
@export var mode_switch_animation_time: float = 1
@export var droplet_fill_tank = 12

# Operating variables
var free_droplets: Array[Droplet] = []
@onready var tank_value: int = tank_size
enum GunState {SHOOT, GATHER}
var state: GunState = GunState.SHOOT
var game_started: bool = false
var on_title_screen: bool = true


func _ready() -> void:
    # Subscribes to signals
    get_node('WaterGunAnimation/Area2D').area_entered.connect(_on_area_entered)
    get_node('/root/Main').start_game.connect(_on_start_game)
    get_node('/root/Main').title_screen_exited.connect(_on_title_screen_exited)
    
    # Initial state
    if GameDataSingleton.is_first_game:
        tank_value = tank_size / 3 * 2


func _physics_process(_delta: float) -> void:
    # @respo: switch mode
    # check state
    state = GunState.SHOOT
    if Input.is_action_pressed("gather"):
        state = GunState.GATHER

    # Set the watergun's position and rotation
    var target: Vector2 = Vector2.ZERO
    var depth_area: DepthArea = DepthArea.new()
    if state == GunState.GATHER:
        animation.set_gathering_position_rotation()
    else:
        var mouse_position: Vector2 = get_global_mouse_position()
        depth_area = background.get_background_depth_area(mouse_position)
        target = animation.set_shooting_position_rotation(depth_area)
    
    # Set the watergun's tank level
    animation.set_water_tank_display(float(tank_value) / tank_size)

    # Shoot
    if state == GunState.SHOOT and Input.is_action_pressed('fire'):
        _shoot(target, depth_area.additional_height_at_stream_apex)


func _shoot(target: Vector2, additional_travel_time: float) -> void:
    # @respo: shoot
    if on_title_screen:
        return

    var mouse_position: Vector2 = get_global_mouse_position()
    if mouse_position.distance_to(marker_front.global_position) < 20:
        return
    if mouse_position.distance_to(marker_back.global_position) < 160:
        return
    

    # update water tank
    if game_started:
        self.tank_value -= shot_cost
    elif tank_value > 20:
        tank_value -= shot_cost
    # check if tank is empty
    if self.tank_value <= 0:
        self.tank_value = 0
        debug_label_tank.text = 'Tank: ' + str(tank_value)
        return
    debug_label_tank.text = 'Tank: ' + str(tank_value)

    # play sound
    water_splash.play()

    # find a free droplet
    var droplet: Droplet = droplet_container.get_droplet()
    droplet.set_course(
        marker_front.global_position,
        target,
        mouse_position,
        additional_travel_time / 500
    )

func _on_area_entered(area: Area2D) -> void:
    # @respo: gather
    if state != GunState.GATHER:
        return
    
    if not area.get_parent() is NeighbourDroplet:
        return

    droplet_collected.play()
    # if is a tuto bottle, free and stop tuto
    if area.get_parent().is_tuto_bottle:
        droplet_collected.play()
        area.get_parent().free()
        get_node('/root/Main/AnimationPlayer').play('tuto_sequence_2')
        tank_value = tank_size
        return
    droplet_collected.play()
    area.get_parent().land()
    tank_value += droplet_fill_tank
    tank_value = clamp(tank_value, 0, tank_size)

    debug_label_tank.text = 'Tank: ' + str(tank_value)


func _on_start_game() -> void:
    game_started = true


func _on_title_screen_exited() -> void:
    on_title_screen = false
