extends Node
class_name DropletContainer
# Responsabilites
# @respo: spawn
# @respo: give droplet


# Signals
signal new_droplet_spawned() # towards window

# References
@onready var droplet_scene: PackedScene = preload('res://scenes/droplet.tscn')
var available_droplets: Array[Droplet] = []

# Game design parameters

# Operating variables
var total_nb_droplet: int = 0


func get_droplet() -> Droplet:
    if available_droplets.is_empty():
        var new_droplet = droplet_scene.instantiate()
        new_droplet.droplet_landed.connect(_on_droplet_landed)
        new_droplet_spawned.emit(new_droplet)
        self.add_child(new_droplet)
        total_nb_droplet += 1
        available_droplets.append(new_droplet)
        
    return available_droplets.pop_front()


func get_nb_in_use() -> int:
    return total_nb_droplet - len(available_droplets)


func _on_droplet_landed(droplet: Droplet) -> void:
    assert(droplet is Droplet)
    available_droplets.append(droplet)
