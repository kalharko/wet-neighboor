extends AnimatedSprite2D
class_name NeighbourWindow
# Responsabilities
# @respo: open/close
# @respo: spawn NeighbourDroplet
# @respo: get hit
# @respo: increase score


# Signals
signal window_hit() # towards main

# References
@onready var window_area: Area2D = get_node("Area2D")
@onready var neighbour_droplet_container = get_node('../../NeighbourDropletContainer')

var neighbour_droplet_scene: PackedScene = preload("res://scenes/neighbour_droplet.tscn")
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Game design parameters
@export var droplet_spawn_probability: float = 0.6
@export var neighbour_droplet_target: Vector2 = Vector2(450, 610)

# Operating variables
var is_window_open: bool = false
var timer: Timer = Timer.new()
var is_active: bool = false
var time_before_closing: float = 0


func _ready() -> void:
	# Subscribes to signals
	get_node('/root/Main/WaterGun/DropletContainer').new_droplet_spawned.connect(_on_new_droplet_spawned)

	# Setup
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(timer, false, Node.INTERNAL_MODE_BACK)


func open_window() -> void:
	is_window_open = true
	self.play("window opening")
	timer.wait_time = time_before_closing
	timer.start()


func close_window() -> void:
	is_window_open = false
	self.play("window closing")


func activate(opening_delay: float, closing_delay: float) -> void:
	is_active = true
	time_before_closing = closing_delay
	timer.wait_time = opening_delay
	timer.start()


func _on_timer_timeout() -> void:
	if is_window_open:
		close_window()
	else:
		open_window()


func _spawn_droplet() -> void:
	var new_droplet: NeighbourDroplet = neighbour_droplet_scene.instantiate()
	var middle_pos: Vector2 = Vector2(
		position.x + (neighbour_droplet_target.x - position.x) / 2,
		position.y - (neighbour_droplet_target.y - position.y) / 2
	)
	new_droplet.set_course(
		position,
		middle_pos,
		neighbour_droplet_target
		)
	neighbour_droplet_container.add_child(new_droplet) # goutte dans la hierarchy enfant de fenetre


func _on_new_droplet_spawned(droplet: Droplet) -> void:
	droplet.droplet_landed.connect(_on_droplet_landed)


func _on_droplet_landed(droplet: Droplet) -> void:
	if not is_window_open:
		return
	
	if not window_area.overlaps_area(droplet.droplet_area):
		return

	close_window()
	window_hit.emit()
	
	if rng.randf() <= droplet_spawn_probability:
		_spawn_droplet()
