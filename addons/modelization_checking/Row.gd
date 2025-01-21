@tool
extends Label


func _on_button_up_pressed():
	var index: int = get_index()
	if index == 0:
		return
	var parent: Node = get_parent()
	for i in range(0, 5):
		var node: Node = parent.get_child(index + i)
		parent.move_child(node, index + i - 5)
	


func _on_button_down_pressed():
	var index: int = get_index()
	var parent: Node = get_parent()
	var child_count: int = parent.get_child_count()
	if index == child_count - 6:
		return

	for i in range(5):
		var node: Node = parent.get_child(index + 9)
		parent.move_child(node, index)
