extends Button
class_name ReplayButton


# References
@onready var game_scene: PackedScene = load("res://scenes/main.tscn")


func _on_pressed() -> void:
    GameDataSingleton.score = 0
    print('Game scene reload by ReplayButton')
    get_tree().change_scene_to_packed(game_scene)
