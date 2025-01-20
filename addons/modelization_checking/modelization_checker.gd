@tool
extends Control
class_name ModelizationChecker
# Responsabilities
# @respo: read a scene file
# @respo: script file info extraction
# @respo: update ERD table

# References
@onready var erd_table: ERDTable = get_node("ERDTable")
@onready var scene_path_line_edit: LineEdit = get_node("ScenePathLineEdit")

# Operating variables
var re_class_name = RegEx.new()
var re_responsabilities = RegEx.new()
var re_signals = RegEx.new()
var re_signal_subscribed_to = RegEx.new()
var re_references = RegEx.new()
var re_gd_params = RegEx.new()
var re_public_func = RegEx.new()
var re_script_paths = RegEx.new()
var re_scene_paths = RegEx.new()


func _ready() -> void:
	# Compile regex expressions
	re_class_name.compile("(?m)^class_name\\s+(\\w+)$")
	re_responsabilities.compile("(?m)^# @respo: (.*)$")
	re_signals.compile("(?m)^signal\\s+(\\w+)\\(\\)$")
	re_signal_subscribed_to.compile("(?m)(\\w+).connect\\(\\w+\\)$")
	re_references.compile("(?m)^@onready var \\w+: \\w+ = get_node\\([\"'](?: ..\\/)*\\/{0,1}(?:\\w+\\/)*?(\\w+)[\"']\\)$")
	re_gd_params.compile("(?m)^@export.*var (\\w+): (\\w+) = .*$")
	re_public_func.compile("(?m)^func ([^_]\\w+)\\(")
	re_script_paths.compile("(?m)^\\[ext_resource type=\"Script\" path=\"(.*?)\"")
	re_scene_paths.compile("(?m)^\\[ext_resource type=\"PackedScene\" .*?path=\"(.*?)\"")


func update_modelization() -> void:
	erd_table.clear_table()

	# get script paths used in the scene
	var script_paths: Array[String] = get_script_paths_from_scene(scene_path_line_edit.text)

	# open each script and add it's line to erd_table
	for script_path in script_paths:
		var file: FileAccess = FileAccess.open(script_path, FileAccess.READ)
		var lines: String = file.get_as_text()
		var regex_match: RegExMatch = re_class_name.search(lines)
		
		# Entity name
		var entity_name: String = script_path.split('/')[-1]
		if regex_match != null:
			entity_name = regex_match.get_string(1)

		# Responsabilities
		var responsabilities: Array[String] = []
		for re_match in re_responsabilities.search_all(lines):
			responsabilities.append(re_match.get_string(1))

		# Relations
		var relations: Array[String] = []
		for re_match in re_signals.search_all(lines):
			relations.append("⚡ " + re_match.get_string(1))
		
		for re_match in re_signal_subscribed_to.search_all(lines):
			relations.append("🔌 " + re_match.get_string(1))
			
		for re_match in re_references.search_all(lines):
			relations.append("🔗 " + re_match.get_string(1))

		# Game design parameters
		var gd_parameters: Array[String] = []
		for re_match in re_gd_params.search_all(lines):
			gd_parameters.append(re_match.get_string(1) + ": " + re_match.get_string(2))

		# Public functions
		var public_functions: Array[String] = []
		for re_match in re_public_func.search_all(lines):
			public_functions.append(re_match.get_string(1))
			
		erd_table.add_line(
			entity_name,
			responsabilities,
			relations,
			gd_parameters,
			public_functions)
			

func get_script_paths_from_scene(scene_path: String) -> Array[String]:
	var scene_file_paths: Array[String] = [scene_path]
	var script_paths: Array[String] = []
	while len(scene_file_paths) > 0:
		var scene_file_path: String = scene_file_paths.pop_front()
		var file: FileAccess = FileAccess.open(scene_file_path, FileAccess.READ)
		var lines: String = file.get_as_text()

		for re_match in re_scene_paths.search_all(lines):
			scene_file_paths.append(re_match.get_string(1))

		for re_match in re_script_paths.search_all(lines):
			script_paths.append(re_match.get_string(1))

	return script_paths
	

func _on_scene_changed(new_root: Node):
	scene_path_line_edit.text = new_root.scene_file_path
	update_modelization()
