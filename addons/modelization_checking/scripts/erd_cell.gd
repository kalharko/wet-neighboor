@tool
extends PanelContainer
class_name ErdCell
# Responsabilities
# @respo: display ErdCellLines


# References
@onready var erd_cell_line: PackedScene = preload("res://addons/modelization_checking/scenes/erd_cell_line.tscn")
@onready var vbox: VBoxContainer = get_node("VBoxContainer")


func clear_content() -> void:
	pass  # TODO

func set_content(content: Array[ErdResource], nb_line_height: int) -> void:
	while vbox.get_child_count() < nb_line_height:
		var cell_line = erd_cell_line.instantiate()
		vbox.add_child(cell_line)
	
	for i in range(vbox.get_child_count()):
		var child: ErdCellLine = vbox.get_child(i)
		child.clear_content()
		if i < len(content):
			child.set_content(content[i])
