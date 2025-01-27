@tool
extends Control
class_name ModelizationChecker
# Responsabilities
# @respo: read a scene file
# @respo: script file info extraction
# @respo: update ERD table


# References
@onready var erd_table: ErdTable = get_node("ScrollContainer/ErdTable")
@onready var scene_path_line_edit: LineEdit = get_node("ScenePathLineEdit")

# Operating variables
var re_script_paths = RegEx.new()
var re_scene_paths = RegEx.new()
var re_packed_scene_paths = RegEx.new()
var current_erd_table: Array[ErdEntityResource] = []


func _ready() -> void:
	# Compile regex expressions
	re_script_paths.compile("(?m)^\\[ext_resource type=\"Script\" path=\"(.*?)\"")
	re_scene_paths.compile("(?m)^\\[ext_resource type=\"PackedScene\" .*?path=\"(.*?)\"")
	re_packed_scene_paths.compile("(?m).*load\\(\"(.*\\.tscn)\"\\)$")


func update_modelization() -> void:
	var erd_table_res: Array[ErdEntityResource] = []
	erd_table.clear()

	# get script paths used in the scene
	var script_paths: Array[String] = _get_script_paths_from_scene(scene_path_line_edit.text)

	# open each script and add it's line to erd_table
	for script_path in script_paths:
		erd_table_res.append(ErdEntityResource._load(script_path))
		erd_table.add_line(erd_table_res[-1])

func initial_scene_load() -> void:
	_on_scene_changed(EditorInterface.get_edited_scene_root())


func _get_line(source: String, target_line: String) -> int:
	var lines = source.split('\n')
	target_line = target_line.rstrip('\n')
	for i in range(len(lines)):
		if lines[i] == target_line:
			return i
	return -1


func _get_script_paths_from_scene(scene_path: String) -> Array[String]:
	var scene_file_paths: Array[String] = [scene_path]
	var explored_scenes: Array[String] = []
	var script_paths: Array[String] = []
	while not scene_file_paths.is_empty():
		var scene_file_path: String = scene_file_paths.pop_front()
		explored_scenes.append(scene_file_path)
		var scene_source: String = FileAccess.open(scene_file_path, FileAccess.READ).get_as_text()

		for re_match in re_scene_paths.search_all(scene_source):
			scene_file_paths.append(re_match.get_string(1))

		for re_match in re_script_paths.search_all(scene_source):
			script_paths.append(re_match.get_string(1))
			var script_source: String = FileAccess.open(re_match.get_string(1), FileAccess.READ).get_as_text()
			for script_re_match in re_packed_scene_paths.search_all(script_source):
				if explored_scenes.has(script_re_match.get_string(1)): continue
				scene_file_paths.append(script_re_match.get_string(1))

	var out: Array[String] = []
	for script_path in script_paths:
		if not out.has(script_path):
			out.append(script_path)
	return out
	

func _on_scene_changed(new_root: Node):
	if new_root == null:
		erd_table.clear()
		return

	scene_path_line_edit.text = new_root.scene_file_path
	update_modelization()
