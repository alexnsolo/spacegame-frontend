class HexTile
    constructor: (x, y) ->
        @coordinates = {x, y}
        @sprite = Game.add.sprite(x * 120, y * 69, 'hex') 
        @sprite.anchor.set(0.5)

    sprite: null
    coordinates: null