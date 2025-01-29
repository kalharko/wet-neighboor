class_name ErdResource

var script_ref: GDScript = null
var script_line: int = 0
var display_text: String = "default display text"
var hover_text: String = "default hover text"


static func _get_line(source: String, target_line: String) -> int:
    var script_lines: PackedStringArray = source.split("\n")
    target_line = target_line.rstrip('\n')
    for i in range(len(script_lines)):
        if script_lines[i] == target_line:
            return i
    return -1


func _to_string() -> String:
    return display_text
