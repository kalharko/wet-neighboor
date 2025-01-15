# Wet Neighboor modelization


## Node hierarchy
_emoji_ 📰 _denotes a node that needs a custom class_

- Main <- Node 📰
    - Camera2D

    - Background: Sprite2D 📰
        - DepthAreaContainer: Node2D
            - DepthArea <- Area2D 📰
                - CollisionPolygon2D
            - ...
        - WindowContainer <- Node2D
            - Window <- SpriteAnimation2D 📰
                - AnimatedSprite2D

    - WaterGun: Node2D 📰
        - Path2D
        - AnimatedSprite2D
            - Marker2D
            - Marker2D
        - DropletContainer <- Node
            - Droplet <- Sprite2D 📰
            - ...


## Responsability Relation Diagram
_class name, responsabiliy, relation_
_⚡means signal, 📁 means reference relation_

- Main
    - keep score, game start, game over, set game speed
    - ⚡Window, ⚡WaterGun

- Background
    - dev acces to background depth
    - 📁DepthArea

- WaterGun
    - aim, shoot, spawn droplet, gather water
    - 📁Droplet, ⚡Droplet, 📁Background

- DepthArea
    - represent the depth of a part of the background
    - x

- Droplet
    - travel, land
    - x

- Window
    - open, close, get hit, respect game speed
    - ⚡WaterGun ⚡Droplet, ⚡Main



## Class definitions
_For each class, lists it's game design parameters, signals, signals connections, references_

- Main
    - ⚡ `game_speed_up_signal`
    - 👾 `game_speed_up_intervals: float`
    - 👾 `initial_game_speed: float`
    - ⚙️ `score: int`
    - 🔌 `_on_window_hit()`
    - 🔌 `_on_water_tank_empty()`

- Background
    - 🔧 `get_depth_parameters(position: Vector2) -> Vector2`

- DepthArea
    - 👾 `additional_height_to_stream_apex: float`
    - 👾 `stream_apex_position_ratio: float`

- WaterGun
    - ⚡ `water_tank_empty_signal`
    - ⚡ `new_droplet_spawned_signal`
    - 👾 `tank_size: int`
    - 👾 `shot_cost: int`
    - 👾 `watergun_rotation_speed: float`
    - ⚙️ `free_droplets: Array[Droplet]`
    - ⚙️ `occupied_droplets: Array[Droplet]`
    - ⚙️ `distance_areas: Array[DepthArea]`
    - 🔌 `_on_droplet_landed()`

- Droplet
    - ⚡ `droplet_landed_signal`
    - ⚙️ `travel_time: float`

- Window
    - ⚡ `window_hit_signal`
    - 👾 `open_time: cuve`
    - 👾 `close_time: curve`
    - 🔌 `_on_game_speed_up()`
