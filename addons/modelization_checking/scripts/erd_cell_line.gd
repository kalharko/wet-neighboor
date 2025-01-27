@tool
extends MarginContainer
class_name ErdCellLine
# Responsabilities
# @respo: display line
# @respo: display hover tool tip
# @respo: go to associated script


# References
@onready var tool_tip_scene: PackedScene = preload("res://addons/modelization_checking/scenes/erd_tool_tip.tscn")
@onready var label: Label = get_node("Label")
var erd_data: ErdResource = null


func _ready() -> void:
	clear_content()


func clear_content() -> void:
	erd_data = null
	label.text = " "
	mouse_default_cursor_shape = 0


func set_content(new_content: ErdResource) -> void:
	erd_data = new_content
	label.text = erd_data.display_text
	mouse_default_cursor_shape = 2


func set_as_folded_marker() -> void:
	label.text = '...'


func _on_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		return

	if not Engine.is_editor_hint():
		print('not in editor')
		return
	
	if erd_data == null:
		print('no erd_data script ref')
		return

	EditorInterface.edit_script(erd_data.script_ref, erd_data.script_line, -1, true)
	EditorInterface.set_main_screen_editor("Script")


func _make_custom_tooltip(for_text: String) -> Object:
	if erd_data == null:
		return Container.new()
	var tool_tip: ErdToolTip = tool_tip_scene.instantiate()
	tool_tip.set_text(erd_data.hover_text)
	return tool_tip
