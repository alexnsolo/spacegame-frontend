class HexGrid
    constructor: (sizeX, sizeY) ->
        for x in [0..sizeX]
            for y in [0..sizeY]
                unless (Helpers.isEven(x) and Helpers.isEven(y)) or (Helpers.isOdd(x) and Helpers.isOdd(y))
                    tile = new HexTile(x, y)
                    @tiles.push(tile)

    tiles: []