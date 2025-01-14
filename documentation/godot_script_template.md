# Godot script template
```py
extends X
class_name X


# Signals

# References

# Game design parameters

# Operating variables


func _ready() -> void:
    # Get references that could not be loaded before

    # Subscribe to signals

    # Setup

    # Initial state
    pass

func _process(_delta: float) -> void:
    pass
```

## Class definition
### Extend
Define what class to extend with the current class.
```py
extends Sprite2D
``` 

### Class name
Define the script as a globally accessible class with the specified name. See [Registering named classes](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#registering-named-classes).
```py
class_name WaterGunSystem
```

## class parameters definition
### Signals
Define the messages this class will be able to emit. See [signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html).
```py
signal droplet_landed(droplet: Droplet)
```

### References
Define the references used by the class. The goal is to decluter the `_ready()` function.
To do so, make use of the [`@onready`](https://docs.godotengine.org/fr/4.x/tutorials/scripting/gdscript/gdscript_basics.html#onready-annotation) annotation`
```py
@onready var my_object_reference_name = get_node("Path/to/object")
```

### Game design parameters
Define the exported variables, used to tune the game's behavior.  
Group variables together with [`@export_group("Group name")`](https://docs.godotengine.org/fr/4.x/tutorials/scripting/gdscript/gdscript_exports.html#grouping-exports).  
Set text hints to be displayed in the editor with double hashtag comments [`##`](https://github.com/godotengine/godot-docs-user-notes/discussions/143#discussioncomment-10868071)
```py
@export_group("Group name")
## This double hashtag comment will appear when hovering the parameter in the editor
@export var parameter: int = 0
```

### Operating variables
Define private variables used to rule the class's behavior. Such as timers, state, temp variables...
```py
# Operating variables
var is_window_open: bool = false
var timer: Timer = Timer.new()
```

## `_ready()`
### References
Some references can not be set with the [`@onready`](#references) trick. Initialise them here. For exemple, lists of references.
```py
func _ready() -> void:
    # Get references
    for child in get_node("Distances").get_children():
        if child is DistanceArea:
            areas.append(child)
```

### Subscribe to signals
Subscribes to [signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html).
```py
func _ready() -> void:
	# Subscribes to signals
	get_node('../../WaterGunSystem').droplet_landed.connect(_on_water_gun_shot)
```

### Setup operating variables
Setup operating variables.
```py
func _ready() -> void:
    # Setup
    timer.one_shot = true
    timer.connect("timeout",Callable(self, "_on_timer_timeout"))
    add_child(timer)
```

### Set initial state
Set the initial satete of the class.
```py
func _ready() -> void:
    # Initial state
    texture = window_closed  #au départ, toutes les fenêtres sont fermées
```

## Class functions definitions
### Process functions (`_process` and/or `_physics_process`)
### Public functions called by other objects
### Private functions used by the object (name preceded by `_`)
### Private functions attached to signals or events (name preceded by `_on_`)
