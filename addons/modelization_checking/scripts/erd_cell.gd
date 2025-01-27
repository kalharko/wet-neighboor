@tool
extends PanelContainer
class_name ErdCell
# Responsabilities
# @respo: display ErdCellLines


# Signals
signal fold_line(line_id: int)
signal unfold_line(line_id: int)

# References
@onready var erd_cell_line: PackedScene = preload("res://addons/modelization_checking/scenes/erd_cell_line.tscn")
@onready var vbox: VBoxContainer = get_node("VBoxContainer")
@onready var fold_button: Button = get_node('FoldButton')

# Operating variables
var is_line_header: bool = false
var is_folded: bool = false
var content: Array[ErdResource] = []
var nb_line_height: int = 0


func _ready() -> void:
	fold_button.visible = false


func clear() -> void:
	for child in vbox.get_children():
		child.free()


func set_content(new_content: Array[ErdResource], new_nb_line_height: int) -> void:
	clear()
	content = new_content
	nb_line_height = new_nb_line_height

	for i in range(nb_line_height):
		var cell_line = erd_cell_line.instantiate()
		vbox.add_child(cell_line)
		if i < len(content):
			cell_line.set_content(content[i])


func set_as_line_header_cell() -> void:
	is_line_header = true
	fold_button.visible = true
	

func _on_fold_button_pressed() -> void:
	if not is_line_header:
		return
	
	if is_folded:
		unfold_line.emit(get_index())
	else:
		fold_line.emit(get_index())


func fold() -> void:
	is_folded = true
	fold_button.text = 'v'
	if vbox.get_child_count() <= 1:
		return

	var children_to_free: Array[ErdCellLine] = []
	for i in range(1, vbox.get_child_count()):
		children_to_free.append(vbox.get_child(i))
	for child in children_to_free:
		child.free()

	# spawn ... cell line
	var cell_line = erd_cell_line.instantiate()
	vbox.add_child(cell_line)
	cell_line.set_as_folded_marker()
	

func unfold() -> void:
	is_folded = false
	fold_button.text = '^'
	set_content(content, nb_line_height)
