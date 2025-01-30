extends Label



func update() -> void:
    # @respo: update flavor text with score
    text = 'Tu as mouillé ' + str(GameDataSingleton.score) + ' voisins.'
