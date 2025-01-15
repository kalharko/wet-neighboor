extends Sprite2D
class_name Background


# References
var depth_areas: Array[DepthArea] = []

func _ready() -> void:
	# Set references
	for child in get_node('DepthAreaContainer').get_children():
		assert(child is DepthArea, "Bad node hierarchy")
		depth_areas.append(child)


func get_containing_area(position: Vector2) -> DepthArea:
	# TODO: Find the DepthArea containing position, return it's parameters
	return depth_areas[0]
