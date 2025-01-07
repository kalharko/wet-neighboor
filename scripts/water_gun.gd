extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# get mouse position
	var mouse_position = get_global_mouse_position()
	# get position of children MarkerFront and MarkerBack
	var marker_front = get_node("MarkerFront").get_global_position()
	var marker_back = get_node("MarkerBack").get_global_position()

	# get gun direction
	var direction = marker_front - marker_back
	
	# get mouse direction
	var mouse_direction = mouse_position - marker_back

	# get angle between gun direction and mouse direction
	var angle = direction.angle_to(mouse_direction)
	
	# rotate gun
	rotation += angle
