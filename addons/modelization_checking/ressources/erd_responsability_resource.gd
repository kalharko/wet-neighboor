extends ErdResource
class_name ErdResponsabilityResource

# Data structure fields
var text: String = "responsability"
var comments: PackedStringArray = []


static func get_all_from_script(script: Script) -> Array[ErdResponsabilityResource]:
    var out: Array[ErdResponsabilityResource] = []
    var re_respo = RegEx.new()
    re_respo.compile("(?m)^(\\s*)# @respo: (.*)$")
    var re_func = RegEx.new()
    re_func.compile("(?m)^func.*$")

    for re_match in re_respo.search_all(script.source_code):
        var responsability = ErdResponsabilityResource.new()
        responsability.text = re_match.get_string(2)
        
        # ErdResource overrides
        responsability.script_ref = script
        responsability.script_line = _get_line(script.source_code, re_match.get_string(0))
        responsability.display_text = responsability.text

        # hover text is it's whole function if it is in a function
        if re_match.get_string(1) == "":
            responsability.hover_text = str(responsability.script_line) + " " + re_match.get_string(0)
        else:
            var lines: PackedStringArray = script.source_code.split('\n')
            # find the previous and next function declarations
            var previous_func: int = 0
            var next_func: int = len(lines) - 1
            for re_func_match in re_func.search_all(script.source_code):
                var line_num = _get_line(script.source_code, re_func_match.get_string(0))
                if line_num < responsability.script_line and line_num > previous_func:
                    previous_func = line_num
                elif line_num > responsability.script_line and line_num < next_func:
                    next_func = line_num - 1
            # move next_func back to the last line of the function
            while lines[next_func] == '':
                next_func -= 1
            # construct the hover text
            responsability.hover_text = ''
            for i in range(previous_func, next_func + 1):
                responsability.hover_text += str(i + 1) + "  " + lines[i] + "\n"
                
            
        out.append(responsability)

    return out
