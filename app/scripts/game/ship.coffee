Game.Sprite.extend 'Ship',
    init: (p) ->
        @_super p,
            asset: _.sample ['ship-fighter.png', 'ship-bomber.png', 'ship-frigate.png', 'ship-carrier.png']
            id: null
            healh: _.sample [50, 76, 100]
            tile: null
            target: null
            scale: 0.17
            angle: _.sample [10,382,133,98]

        @on 'tileChanged'
        @trigger 'tileChanged' if @p.tile

    tileChanged: () ->
        if @p.tile
            @p.x = @p.tile.p.x
            @p.y = @p.tile.p.y

    moveToTile: (tile) ->
        @p.tile = tile
        @trigger 'tileChanged'

    targetShip: (ship) ->
        @p.target = ship

    fireAt: (ship) ->
        # return unless ship.p.alive
        # bullet = new Bullet(@p, ship)


