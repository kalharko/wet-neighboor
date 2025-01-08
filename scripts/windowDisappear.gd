extends Sprite2D

@export var initial_texture: Texture2D
@export var clicked_texture: Texture2D

var is_clicked = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = initial_texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT  and event.pressed:
		if not is_clicked:
			texture = clicked_texture  # Change la texture au clic
			is_clicked = true
