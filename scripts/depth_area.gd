extends Area2D
class_name DepthArea


# References
@onready var polygon: CollisionPolygon2D = get_node("CollisionPolygon2D")

# Game design parameters
@export var water_stream_height_at_apex: float = 0
@export var water_stream_apex_pos_ratio: float = 0.5


func contains(point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(point, polygon.polygon)
