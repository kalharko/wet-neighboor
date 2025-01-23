extends ErdResource
class_name ErdResponsabilityResource

# Data structure fields
var text: String = "responsability"
var comments: PackedStringArray = []


static func get_all_from_script(script: Script) -> Array[ErdResponsabilityResource]:
	var out: Array[ErdResponsabilityResource] = []
	var re = RegEx.new()
	re.compile("(?m)^# @respo: (.*)$")

	for re_match in re.search_all(script.source_code):
		var responsability = ErdResponsabilityResource.new()
		responsability.text = re_match.get_string(1)
		
		# ErdResource overrides
		responsability.script_ref = script
		responsability.script_line = _get_line(script.source_code, re_match.get_string(0))
		responsability.display_text = responsability.text
		responsability.hover_text = str(responsability.script_line) + " " + re_match.get_string(0)
		out.append(responsability)

	return out
