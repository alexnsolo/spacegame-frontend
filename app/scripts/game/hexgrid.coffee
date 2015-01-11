class HexGrid
    tiles: []
    
    constructor: (sizeX, sizeY) ->
        for x in [0..sizeX]
            for y in [0..sizeY]
                unless (Helpers.isEven(x) and Helpers.isEven(y)) or (Helpers.isOdd(x) and Helpers.isOdd(y))
                    tile = new HexTile(x, y)
                    @tiles.push(tile)


    findTileByCoords: (x, y) ->
        _.find tiles, (tile) -> tile.x is x and tile.y is y