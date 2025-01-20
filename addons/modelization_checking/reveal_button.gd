@tool
extends ColorRect


# References
@onready var button_up: Button = get_node('ButtonUp')
@onready var button_down: Button = get_node('ButtonDown')


func _ready() -> void:
	_on_mouse_exited()


func _on_mouse_entered() -> void:
	button_up.visible = true
	button_down.visible = true


func _on_mouse_exited() -> void:
	button_up.visible = false
	button_down.visible = false
