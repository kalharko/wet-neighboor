extends ErdResource
class_name ErdPublicFuncResource

# Data structure fields
var name: String = "name"
var params: Dictionary = {}
var return_type: String = "return"


static func get_all_from_script(script: Script) -> Array[ErdPublicFuncResource]:
    var out: Array[ErdPublicFuncResource] = []
    var re_func = RegEx.new()
    re_func.compile("(?m)^func.*$")
    var re_public_func = RegEx.new()
    re_public_func.compile("(?m)^func ([^_]\\w+)\\((.*)\\).*:")
    var re_has_return_type = RegEx.new()
    re_has_return_type.compile(" -> .+:")

    for re_match in re_public_func.search_all(script.source_code):
        var public_func = ErdPublicFuncResource.new()
        public_func.name = re_match.get_string(1)
        for param in re_match.get_string(2).split(", "):
            if param == "": continue
            public_func.params[param.split(": ")[0]] = param.split(": ")[1]
        var has_return_type: bool = re_has_return_type.search(re_match.get_string(0), 0) != null
        public_func.script_line = _get_line(script.source_code, re_match.get_string(0))

        # Get function body
        var lines: PackedStringArray = script.source_code.split('\n')
        # find the previous and next function declarations
        var next_func: int = len(lines) - 1
        for re_func_match in re_func.search_all(script.source_code):
            var line_num = _get_line(script.source_code, re_func_match.get_string(0))
            if line_num > public_func.script_line and line_num < next_func:
                next_func = line_num - 1
        # move next_func back to the last line of the function
        while lines[next_func] == '':
            next_func -= 1
        # construct the hover text
        public_func.hover_text = ''
        for i in range(public_func.script_line, next_func + 1):
            public_func.hover_text += str(i + 1) + "  " + lines[i] + "\n"

        # ErdResource overrides
        public_func.script_ref = script
        if has_return_type:
            public_func.display_text = public_func.name
        else:
            public_func.display_text = '❌' + public_func.name
            public_func.hover_text = '❌ missing return type\n' + public_func.hover_text
        out.append(public_func)
    return out
