extends Sprite2D

var rng = RandomNumberGenerator.new()

@export var window_open: Texture2D
@export var window_closed: Texture2D

var is_window_open = false
var timer: Timer

signal window_closed_signal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = window_closed  #au départ, toutes les fenêtres sont fermées

	timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout",Callable(self, "_on_timer_timeout"))
	add_child(timer)

	open_time = rng.randf_range(3.0, 10.0)  # un délai d'ouverture aléatoire
	timer.wait_time = current_open_time
	timer.start()

@export var open_time = rng.randf_range(3.0, 10.0)
@export var close_time = rng.randf_range(1.0, 10.0)

# variables utilisées pour adapter le temps d'ouverture/fermerture : de plus en plus rapide
var current_open_time = open_time  
var current_close_time = close_time 

func _on_timer_timeout():
	if is_window_open:
		close_window()
	else:
		open_window()

func open_window() -> void:
	is_window_open = true
	texture = window_open
	
	current_close_time =  max(1, current_close_time * 0.9)
	timer.wait_time = current_close_time 
	timer.start()

func close_window() -> void:
	is_window_open = false
	texture = window_closed

	current_open_time = max(1, current_open_time * 0.9)  
	timer.wait_time = current_open_time
	timer.start()

	window_closed_signal.emit()
	
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_window_open:
			close_window()