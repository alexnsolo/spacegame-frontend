class HexGrid
    constructor: (sizeX, sizeY) ->
        for x in [-sizeX..sizeX]
            for y in [-sizeY..sizeY]
                unless (Helpers.isEven(x) and Helpers.isEven(y)) or (Helpers.isOdd(x) and Helpers.isOdd(y))
                    tile = new HexTile(x, y)
                    @tiles.push(tile)

    tiles: []