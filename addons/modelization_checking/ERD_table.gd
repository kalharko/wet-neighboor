@tool
extends GridContainer
class_name ERDTable
# Responsabilities
# @respo: Display ERD table lines


# References
@onready var grid_cell_label: PackedScene = preload("res://addons/modelization_checking/grid_cell_label.tscn")
@onready var grid_cell_label_movable: PackedScene = preload("res://addons/modelization_checking/grid_cell_label_movable.tscn")


func clear_table() -> void:
	for child in get_children():
		if child is Label:
			child.free()

func add_line(
	entity_name: String,
	responsabilities: Array[String],
	relations: Array[String],
	gd_parameters: Array[String],
	public_functions: Array[String]) -> void:
	# Instantiate the grid container line
	var labels: Array[Label] = []
	for i in range(5):
		var label: Label = grid_cell_label.instantiate()
		if i == 0:
			label = grid_cell_label_movable.instantiate()
		labels.append(label)
		add_child(label)

	# pad cell text with empty lines
	var nb_lines: int = max(len(relations), len(gd_parameters), len(public_functions), len(responsabilities), 1)
	for i in range(1, nb_lines):
		entity_name += "\n "

	for i in range(len(responsabilities), nb_lines):
		responsabilities.append(" ")

	for i in range(len(relations), nb_lines):
		relations.append(" ")
	
	for i in range(len(gd_parameters), nb_lines):
		gd_parameters.append(" ")
	
	for i in range(len(public_functions), nb_lines):
		public_functions.append(" ")
		
	labels[0].text = entity_name
	labels[1].text = "\n".join(responsabilities)
	labels[2].text = "\n".join(relations)
	labels[3].text = "\n".join(gd_parameters)
	labels[4].text = "\n".join(public_functions)


func swap_line(line_id1: int, line_id2: int):
	pass
