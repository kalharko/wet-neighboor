extends ErdResource
class_name ErdPublicFuncResource

# Data structure fields
var name: String = "name"
var params: Dictionary = {}
var return_type: String = "return"


static func get_all_from_script(script: Script) -> Array[ErdPublicFuncResource]:
	var out: Array[ErdPublicFuncResource] = []
	var re = RegEx.new()
	re.compile("(?m)^func ([^_]\\w+)\\((.*)\\) -> ([^:]*):")
	for re_match in re.search_all(script.source_code):
		var public_func = ErdPublicFuncResource.new()
		public_func.name = re_match.get_string(1)
		for param in re_match.get_string(2).split(", "):
			if param == "": continue
			public_func.params[param.split(": ")[0]] = param.split(": ")[1]
		public_func.return_type = re_match.get_string(3)

		# ErdResource overrides
		public_func.script_ref = script
		public_func.display_text = public_func.name
		public_func.script_line = _get_line(script.source_code, re_match.get_string(0))
		public_func.hover_text = str(public_func.script_line) + " " + re_match.get_string(0)
		out.append(public_func)
	return out
