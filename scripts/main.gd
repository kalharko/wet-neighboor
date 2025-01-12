extends Node


# References
@export var score_label: Label

# Operating variables
var score: int = 0


func _ready() -> void:
	# Subscribes to signals
	for window in get_node('Windows').get_children():
		window.window_closed_signal.connect(_on_window_closed_signal)


func _process(_delta: float) -> void:
	pass


func _on_window_closed_signal() -> void:
	score += 1
	score_label.text = 'Score: ' + str(score)
