@tool
extends HSplitContainer
class_name ErdTable
# Responsabilities
# @respo: Display ERD table lines


# References
@onready var erd_cell_scene: PackedScene = preload("res://addons/modelization_checking/scenes/erd_cell.tscn")
var columns: Array[ErdColumn] = []


func _ready() -> void:
    # search for columns in nested children
    var un_explored = get_children()
    while not un_explored.is_empty():
        var node = un_explored.pop_front()
        un_explored.append_array(node.get_children())
        if node is ErdColumn:
            columns.append(node)
            node.new_cell_spawned.connect(_on_new_cell_spawned)
            node.size.x = size.x / 5


func clear() -> void:
    for column in columns:
        column.clear()


func add_line(erd_entity: ErdEntityResource) -> void:
    # Instantiate the five cells
    for i in range(5):
        match i:
            0:
                columns[i].add_cell(erd_entity.get_name(), erd_entity.nb_line_height)
            1:
                columns[i].add_cell(erd_entity.get_responsabilities(), erd_entity.nb_line_height)
            2:
                columns[i].add_cell(erd_entity.get_relations(), erd_entity.nb_line_height)
            3:
                columns[i].add_cell(erd_entity.get_gd_parameters(), erd_entity.nb_line_height)
            4:
                columns[i].add_cell(erd_entity.get_public_functions(), erd_entity.nb_line_height)


func _on_new_cell_spawned(cell: ErdCell) -> void:
    cell.fold_line.connect(_on_fold_line)
    cell.unfold_line.connect(_on_unfold_line)


func _on_fold_line(line_id: int) -> void:
    for column in columns:
        column.fold_line(line_id)


func _on_unfold_line(line_id: int) -> void:
    for column in columns:
        column.unfold_line(line_id)
