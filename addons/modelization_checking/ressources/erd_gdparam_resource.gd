extends ErdResource
class_name ErdGDParamResource

# Data structure fields
var name: String = "name"
var type: String = "type"
var default_value: String = "default"


static func get_all_from_script(script: Script) -> Array[ErdGDParamResource]:
	var out: Array[ErdGDParamResource] = []
	var re = RegEx.new()
	re.compile("(?m)^@export.*var (\\w+): (\\w+) = (.*)$")
	
	for re_match in re.search_all(script.source_code):
		var gd_param = ErdGDParamResource.new()
		gd_param.name = re_match.get_string(1)
		gd_param.type = re_match.get_string(2)
		gd_param.default_value = re_match.get_string(3)

		# ErdResource overrides
		gd_param.script_ref = script
		gd_param.script_line = _get_line(script.source_code, re_match.get_string(0))
		gd_param.display_text = gd_param.name
		gd_param.hover_text = str(gd_param.script_line) + " " + re_match.get_string(0)
		out.append(gd_param)

	return out
