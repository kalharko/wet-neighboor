@tool
extends Button
class_name TextSizeButton
# Responsabilities
# @respo: increase/decrease text size


# References
@onready var label_settings: Array[LabelSettings] = [
    preload("res://addons/modelization_checking/ressources/h1_label_settings.tres"),
    preload("res://addons/modelization_checking/ressources/h2_label_settings.tres"),
    preload("res://addons/modelization_checking/ressources/p_label_settings.tres"),
    preload("res://addons/modelization_checking/ressources/tool_tip_label_settings.tres")
]

# Game design parameter
## value added to the label setting size
@export var text_label_settings_size_delta: int = 1

func _on_pressed() -> void:
    for setting in label_settings:
        setting.font_size += text_label_settings_size_delta
