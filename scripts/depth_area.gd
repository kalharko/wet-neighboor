extends Area2D
class_name DepthArea
# Responsabilites
# @respo: define background depth

# References
@onready var polygon: CollisionPolygon2D = get_node("CollisionPolygon2D")

# Game design parameters
@export var additional_height_at_stream_apex: float = 0
@export var stream_apex_position_ration: float = 0.5




func contains(point: Vector2) -> bool:
    return Geometry2D.is_point_in_polygon(point, polygon.polygon)
