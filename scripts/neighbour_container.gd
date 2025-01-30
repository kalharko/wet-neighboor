extends Control
class_name NeighbourContainer


# References
var children: Array[Sprite2D] = []

# Game design parameters
## Score needed to display all neighbours 
@export var all_neighbours_score: int = 100

func _ready() -> void:
    for child in get_children():
        assert(child is Sprite2D)
        child.visible = false
        children.append(child)


func display_neighbours() -> void:
    # @respo: display nb of angry neighbours function of score
    visible = true
    var score: int = GameDataSingleton.score
    assert(score >= 0)
    var nb_visible_neighbour_needed: int = float(score) * float(children.size()) / float(all_neighbours_score)
    if nb_visible_neighbour_needed > children.size():
        nb_visible_neighbour_needed = children.size()

    for i in range(nb_visible_neighbour_needed):
        children[-(i + 1)].visible = true
