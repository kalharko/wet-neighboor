extends Node


@export var score_label: Label


var score: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Subscribes to window's signals
	for window in get_node('Windows').get_children():
		window.window_closed_signal.connect(_on_window_closed_signal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_window_closed_signal() -> void:
	score += 1
	score_label.text = 'Score: ' + str(score)
