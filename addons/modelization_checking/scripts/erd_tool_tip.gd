@tool
extends PanelContainer
class_name ErdToolTip
# Responsabilities
# @respos: display a tooltip


# References
@onready var label: Label = get_node("MarginContainer/Label")


func set_text(text: String) -> void:
	if not label:
		await self.ready

	label.text = text
