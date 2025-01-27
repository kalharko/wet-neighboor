@tool
extends VBoxContainer
class_name ErdColumn


# Signals
signal new_cell_spawned(cell: ErdCell)

# References
@onready var erd_cell_scene: PackedScene = preload("res://addons/modelization_checking/scenes/erd_cell.tscn")

# Game design parameters
@export var is_header_column: bool = false


func clear() -> void:
	for child in get_children():
		if child is ErdCell:
			child.free()


func add_cell(erd_data: Array[ErdResource], nb_line_height: int):
	var cell: ErdCell = erd_cell_scene.instantiate()
	add_child(cell)
	if is_header_column:
		cell.set_as_line_header_cell()
	cell.set_content(erd_data, nb_line_height)
	new_cell_spawned.emit(cell)


func fold_line(line_id: int) -> void:
	get_child(line_id).fold()


func unfold_line(line_id: int) -> void:
	get_child(line_id).unfold()
