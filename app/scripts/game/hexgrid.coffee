Game.Sprite.extend 'HexGrid',
    init: (p) ->
        @_super p,
            sizeX: 10
            sizeY: 10
            tiles: []

        for x in [0..@p.sizeX]
            for y in [0..@p.sizeY]
                unless (Helpers.isEven(x) and Helpers.isEven(y)) or (Helpers.isOdd(x) and Helpers.isOdd(y))
                    gridCoordinates = {x, y}
                    tile = new Game.HexTile({gridCoordinates})
                    tile.p.x = x * 120
                    tile.p.y = y * 69
                    @p.tiles.push(tile)

        @on 'inserted'

    inserted: () ->
        _.each @p.tiles, (tile) => @stage.insert tile

    findTileByCoords: (x, y) ->
        _.find @p.tiles, (tile) -> tile.x is x and tile.y is y