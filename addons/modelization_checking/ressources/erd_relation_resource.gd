extends ErdResource
class_name ErdRelationResource

# Data structure fields
enum RelationType {
	SIGNAL_SENDER,
	SIGNAL_SUBSCRIBER,
	COLLISION_MONITORING,
	DIRECT_REF,
	CHILD,
	PARENT,
	UNDEFINED
}
var type: RelationType = RelationType.UNDEFINED
var relation_to: String = "relation to"
var relation_name: String = "relation name"


static func get_all_from_script(script: Script) -> Array[ErdRelationResource]:
	var out: Array[ErdRelationResource] = []

	# Signals
	var re_signals = RegEx.new()
	re_signals.compile("(?m)^signal\\s+(\\w+)\\(\\)$")
	for re_match in re_signals.search_all(script.source_code):
		var relation = ErdRelationResource.new()
		relation.type = ErdRelationResource.RelationType.SIGNAL_SENDER
		relation.relation_to = ""
		relation.relation_name = re_match.get_string(1)
		
		# ErdResource overrides
		relation.script_ref = script
		relation.script_line = _get_line(script.source_code, re_match.get_string(0))
		relation.display_text = "⚡ " + relation.relation_name
		relation.hover_text = str(relation.script_line) + " " + re_match.get_string(0)
		out.append(relation)
	
	# Signals subscribed to
	var re_signals_subscribed_to = RegEx.new()
	re_signals_subscribed_to.compile("(?m)(\\w+).connect\\(\\w+\\)$")
	for re_match in re_signals_subscribed_to.search_all(script.source_code):
		var relation = ErdRelationResource.new()
		relation.type = ErdRelationResource.RelationType.SIGNAL_SUBSCRIBER
		relation.relation_to = ""
		relation.relation_name = re_match.get_string(1)
		
		# ErdResource overrides
		relation.script_ref = script
		relation.script_line = _get_line(script.source_code, re_match.get_string(0))
		relation.display_text = "🔌 " + relation.relation_name
		relation.hover_text = str(relation.script_line) + " " + re_match.get_string(0)
		out.append(relation)

	# References
	var re_references = RegEx.new()
	re_references.compile("(?m)^@onready var \\w+: \\w+ = get_node\\([\"'](?: ..\\/)*\\/{0,1}(?:\\w+\\/)*?(\\w+)[\"']\\)$")
	for re_match in re_references.search_all(script.source_code):
		var relation = ErdRelationResource.new()
		relation.type = ErdRelationResource.RelationType.DIRECT_REF
		relation.relation_to = ""
		relation.relation_name = re_match.get_string(1)
		
		# ErdResource overrides
		relation.script_ref = script
		relation.script_line = _get_line(script.source_code, re_match.get_string(0))
		relation.display_text = "🔗 " + relation.relation_name
		relation.hover_text = str(relation.script_line) + " " + re_match.get_string(0)
		out.append(relation)
	
	# TODO: collision relations

	return out
