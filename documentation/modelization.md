# Wet Neighboor modelization


## Node hierarchy
_emoji_ 📰 _denotes a node that needs a custom class_

- Main <- Node 📰
    - Camera2D
    - TextureRect

    - WaterGun <- Node2D 📰
        - AnimatedSprite2D
        - MouseArea: Area2D
            - CollisionShape2D
        
    - DistanceAreaContainer: Node2D
        - DistanceArea <- Area2D 📰
            - CollisionPolygon2D
        - ...

    - DropletContainer: Node
        - Droplet <- Sprite2D 📰
        - ...

    - WindowContainer: Node2D
        - Window <- SpriteAnimation2D 📰
            - AnimatedSprite2D


## Responsability Relation Diagram
_class name, responsabiliy, relation_
_:zap: means signal, 📁 means reference relation_

- Main
    - keep score, game start, game over, set game speed
    - :zap: Window, :zap: WaterGun

- WaterGun
    - aim, shoot, gather water
    - 📁 Droplet, :zap: Droplet, 📁DistanceArea

- DistanceArea
    - gun-buildings distances
    - x

- Droplet
    - travel, land
    - x

- Window
    - open, close, get hit, respect game speed
    - :zap: Droplet, :zap: Main



## Class definitions
_For each class, lists it's game design parameters, signals, signals connections, references_

- Main
    - ⚡ `signal game_speed_up`
    - 👾 `speed_up_intervals: float`
    - ⚙️ `score: int`
    - 🔌 `_on_window_hit()`
    - 🔌 `_on_water_tank_empty()`

- WaterGun
    - ⚡ `signal water_tank_empty`
    - 👾 `tank_size: int`
    - 👾 `shot_cost: int`
    - 👾 `watergun_rotation_speed: float`
    - ⚙️ `free_droplets: Array[Droplet]`
    - ⚙️ `occupied_droplets: Array[Droplet]`
    - ⚙️ `distance_areas: Array[DistanceArea]`
    - 🔌 `_on_droplet_landed()`

- DistanceArea
    - 👾 `additional_height_to_stream_apex: float`
    - 👾 `stream_apex_position_ratio: float`

- Droplet
    - ⚡ `signal droplet_landed`
    - ⚙️ `travel_time: float`

- Window
    - ⚡ `signal window_hit`
    - 👾 `open_time: cuve`
    - 👾 `close_time: curve`
    - 🔌 `_on_game_speed_up()`
