extends Sprite2D
class_name Background


# References
var depth_areas: Array[DepthArea] = []

func _ready() -> void:
	# Set references
	for child in get_node('DepthAreaContainer').get_children():
		assert(child is DepthArea, "Bad node hierarchy")
		depth_areas.append(child)


func get_containing_area(point: Vector2) -> DepthArea:
	# TODO: Find the DepthArea containing position, return it's parameters
	for depth_area in depth_areas:
		if depth_area.contains(point):
			return depth_area
	
	# if this code is reached, means the DepthAreas are badly configured
	# assert that the mouse is outside of the game window
	var mpos: Vector2 = get_global_mouse_position()
	assert(mpos.x < 0 or mpos.x > get_viewport().size.x or mpos.y < 0 or mpos.y > get_viewport().size.y, "Bad DepthArea configuration")
	# by default return empty DepthArea
	return DepthArea.new()
