extends ErdResource
class_name ErdNameResource

# Data structure fields
var name: String = "name"


static func get_all_from_script(script: Script) -> Array[ErdNameResource]:
	var out: Array[ErdNameResource] = []
	var re = RegEx.new()
	re.compile("(?m)^class_name\\s+(\\w+)$")
	for re_match in re.search_all(script.source_code):
		var name = ErdNameResource.new()
		name.name = re_match.get_string(1)
		
		# ErdResource overrides
		name.script_ref = script
		name.script_line = _get_line(script.source_code, re_match.get_string(0))
		name.display_text = name.name
		name.hover_text = str(name.script_line) + " " + re_match.get_string(0)
		out.append(name)
		
	if len(out) == 0:
		var name = ErdNameResource.new()
		name.name = script.resource_path.get_file().split('/')[-1]
		name.script_ref = script
		name.script_line = 1
		name.display_text = name.name
		name.hover_text = str(name.script_line) + " " + script.resource_path
		out.append(name)

	return out
