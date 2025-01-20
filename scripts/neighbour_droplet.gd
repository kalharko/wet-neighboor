extends Sprite2D
class_name NeighbourDroplet
# Responsabilities
# @respo: moving
# @respo: disappear


# Signals

# References

# Game design parameters
@export var speed: float = 140.0


# Operating variables
var is_collected: bool = false
var screen_height: int = int(ProjectSettings.get_setting("display/window/size/viewport_height"))

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	position.y += speed * _delta 
	if global_position.y > screen_height:
		queue_free()  #Remove the droplet from the scene if it attains the bottom of the screen, so if the player didn't collect the droplet
	
func set_course(start: Vector2) -> void:
	visible = true
	position = start

	
	
#func collect()->void:
#	is_collected = true
#	droplet_collected.emit()
#	queue_free() # Remove the droplet from the scene if i has been collected by the player's gun
