extends Sprite2D


# Signals
signal window_hit_signal

# References
@export var window_open: Texture2D
@export var window_closed: Texture2D
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@onready var window_area: Area2D = get_node("Area2D")

var neighbour_droplet_scene: PackedScene = preload("res://scenes/neighbour_droplet.tscn")

# Game design parameters
@export var open_time: float = rng.randf_range(3.0, 10.0)
@export var close_time: float = rng.randf_range(1.0, 10.0)

# Operating variables
var is_window_open: bool = false
var timer: Timer = Timer.new()
# variables utilisées pour adapter le temps d'ouverture/fermerture : de plus en plus rapide
var current_open_time: float = open_time  
var current_close_time: float = close_time 


func _ready() -> void:
	# Subscribes to signals
	get_node('/root/NewMain/WaterGun').new_droplet_spawned_signal.connect(_on_new_droplet_spawned)

	# Setup
	timer.one_shot = true
	timer.connect("timeout",Callable(self, "_on_timer_timeout"))
	add_child(timer)

	# Initial state
	texture = window_closed  #au départ, toutes les fenêtres sont fermées

	open_time = rng.randf_range(3.0, 10.0)  # un délai d'ouverture aléatoire
	timer.wait_time = current_open_time
	timer.start()


func open_window() -> void:
	is_window_open = true
	texture = window_open
	
	current_close_time =  max(1, current_close_time * 0.9)
	timer.wait_time = current_close_time 
	timer.start()


func close_window() -> void:
	is_window_open = false
	
	#test aléatoire
	#si on lance - anim 
	#asynchrone - a la fin appelle la fonction spawn goutte en haut
	texture = window_closed

	current_open_time = max(1, current_open_time * 0.9)  
	timer.wait_time = current_open_time
	timer.start()
	var new_droplet: NeighbourDroplet = neighbour_droplet_scene.instantiate()
	new_droplet.set_course(position)
	add_child(new_droplet) #goutte dans la hierarchy enfant de fenetre


func _on_timer_timeout() -> void:
	if is_window_open:
		close_window()
	else:
		open_window()


func _on_new_droplet_spawned(droplet: Droplet) -> void:
	droplet.droplet_landed_signal.connect(_on_droplet_landed)

func _on_droplet_landed(droplet: Droplet) -> void:
	if not is_window_open:
		return
	
	if not window_area.overlaps_area(droplet.droplet_area):
		return

	close_window()
	window_hit_signal.emit()
