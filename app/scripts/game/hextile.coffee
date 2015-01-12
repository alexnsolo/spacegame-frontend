Game.Sprite.extend 'HexTile',
    init: (p) ->
        @_super p, 
            asset: 'hexagon.png'
            gridCoordinates: {x: 0, y: 0}

        @on 'inserted'

    inserted: () ->
        coordLabel = new Game.UI.Text
            label: 'X' + @p.gridCoordinates.x + '  Y' + @p.gridCoordinates.y,
            color: 'rgba(255,255,255,0.5)',
            x: 0,
            y: 0

        @stage.insert coordLabel, @
