extends AnimatedSprite2D


# Operating variables
var is_first_time_click: bool = true


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if is_first_time_click:
            var animation_player: AnimationPlayer = get_node('/root/Main/AnimationPlayer')
            if animation_player.current_animation == 'show_title_screen' and animation_player.is_playing():
                return
            
            print("Fake Window is clicked")
            is_first_time_click = false
            get_node('/root/Main').start_tuto()
