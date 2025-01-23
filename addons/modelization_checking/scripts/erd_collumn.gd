@tool
extends VBoxContainer
class_name ErdColumn


# References
@onready var erd_cell_scene: PackedScene = preload("res://addons/modelization_checking/scenes/erd_cell.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func clear() -> void:
	for child in get_children():
		if child is ErdCell:
			child.free()


func add_cell(erd_data: Array[ErdResource], nb_line_height: int):
	var cell: ErdCell = erd_cell_scene.instantiate()
	add_child(cell)
	cell.set_content(erd_data, nb_line_height)
