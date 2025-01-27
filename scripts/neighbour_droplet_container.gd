extends Node
class_name NeighbourDropletContainer


# References
@onready var available_neighbour_droplets: Array[NeighbourDroplet] = []
@onready var neighbour_droplet_scene: PackedScene = preload('res://scenes/neighbour_droplet.tscn')

# Operating variables
var total_nb_droplet: int = 0


func get_droplet()-> NeighbourDroplet:
	if available_neighbour_droplets.is_empty():
		var new_droplet = neighbour_droplet_scene.instantiate()
		new_droplet.neighbour_droplet_landed.connect(_on_neighbour_droplet_landed)
		self.add_child(new_droplet)
		available_neighbour_droplets.append(new_droplet)
		total_nb_droplet += 1
	
	print('neighbour droplet container: get_droplet() ' + str(available_neighbour_droplets[0].get_instance_id()))
	return available_neighbour_droplets.pop_front()


func get_nb_in_use() -> int:
	return total_nb_droplet - len(available_neighbour_droplets)
	
func _on_neighbour_droplet_landed(droplet:NeighbourDroplet)->void:
	assert(droplet is NeighbourDroplet)
	print('neighbour droplet container: _on_neighbour_droplet_landed() ' + str(droplet.get_instance_id()))
	available_neighbour_droplets.append(droplet)
