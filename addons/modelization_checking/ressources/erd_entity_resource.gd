extends ErdResource
class_name ErdEntityResource


# Data structure fields
var script_path: String = ""
var nb_line_height: int = 0
var entity_name: Array[ErdNameResource] = []
var responsabilities: Array[ErdResponsabilityResource] = []
var relations: Array[ErdRelationResource] = []
var gd_parameters: Array[ErdGDParamResource] = []
var public_functions: Array[ErdPublicFuncResource] = []


func _to_string() -> String:
	var out: String = 'ErdEntityResource\n'
	out += 'entity_name: ' + str(entity_name) + '\n'
	out += 'responsabilities: ' + str(responsabilities) + '\n'
	out += 'relations: ' + str(relations) + '\n'
	out += 'gd_parameters: ' + str(gd_parameters) + '\n'
	out += 'public_functions: ' + str(public_functions) + '\n'
	return out


static func _load(script_path: String) -> ErdEntityResource:
	# Entity script
	var out = ErdEntityResource.new()
	out.script_path = script_path
	out.script_ref = load(script_path)
	var script_lines: PackedStringArray = out.script_ref.source_code.split("\n")

	# Entity name
	out.entity_name = ErdNameResource.get_all_from_script(out.script_ref)

	# Entity responsabilities
	out.responsabilities = ErdResponsabilityResource.get_all_from_script(out.script_ref)

	# Entity relations
	out.relations = ErdRelationResource.get_all_from_script(out.script_ref)

	# Entity gd_parameters
	out.gd_parameters = ErdGDParamResource.get_all_from_script(out.script_ref)

	# Entity public_functions
	out.public_functions = ErdPublicFuncResource.get_all_from_script(out.script_ref)

	out.nb_line_height = max(
		len(out.entity_name),
		len(out.responsabilities),
		len(out.relations),
		len(out.gd_parameters),
		len(out.public_functions)
	)
	return out


func get_name() -> Array[ErdResource]:
	return _get_array_as_erd_resource(entity_name)


func get_responsabilities() -> Array[ErdResource]:
	return _get_array_as_erd_resource(responsabilities)


func get_relations() -> Array[ErdResource]:
	return _get_array_as_erd_resource(relations)


func get_gd_parameters() -> Array[ErdResource]:
	return _get_array_as_erd_resource(gd_parameters)


func get_public_functions() -> Array[ErdResource]:
	return _get_array_as_erd_resource(public_functions)


func _get_array_as_erd_resource(array: Array) -> Array[ErdResource]:
	# getter functions necessary because of gdscript limitations
	# https://github.com/godotengine/godot/issues/83876
	var out: Array[ErdResource] = []
	for resource in array:
		var erd_resource = ErdResource.new()
		erd_resource.script_ref = resource.script_ref
		erd_resource.script_line = resource.script_line
		erd_resource.display_text = resource.display_text
		erd_resource.hover_text = resource.hover_text
		out.append(erd_resource)
	return out
