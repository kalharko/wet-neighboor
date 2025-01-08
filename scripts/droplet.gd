extends Sprite2D

class_name Droplet

var nb_step: int = 0
var current_step: int = 0
var curve_start: Vector2
var curve_middle: Vector2
var curve_end: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	if current_step >= nb_step:
		return

	current_step += 1
	if current_step >= nb_step:
		self.visible = false
		get_node('../../WaterGunSystem').free_droplets.append(self)
		return
	
	# set position along bezier curve
	var t: float = float(self.current_step) / float(self.nb_step)
	var new_pos: Vector2 = _quadratic_bezier(
		self.curve_start,
		self.curve_middle,
		self.curve_end,
		t
	)
	self.position = new_pos

	# set rotation to normal to bezier curve
	var normal: Vector2 = _normal_to_quadratic_bezier(
		self.curve_start,
		self.curve_middle,
		self.curve_end,
		t
	)
	self.rotation = normal.angle() + PI

func set_course(start: Vector2, middle: Vector2, end: Vector2, nb_step: int) -> void:
	self.visible = true
	self.position = start
	self.nb_step = nb_step
	self.current_step = 0

	self.curve_start = start
	self.curve_middle = middle
	self.curve_end = end
	

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)

	var r = q0.lerp(q1, t)
	return r

func _normal_to_quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	return p0 * (2 * t - 2) + (2 * p2 - 4 * p1) * t + 2 * p1
