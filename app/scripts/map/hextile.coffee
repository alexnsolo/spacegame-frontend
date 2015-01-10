class HexTile
    constructor: (x, y) ->
        @x = x
        @y = y
        @sprite = Game.add.sprite(@x * 120, @y * 69, 'hex') 
        @sprite.anchor.set(0.5)

    sprite: null
    x: null
    y: null
