Game.Sprite.extend 'Ship',
    init: (p) ->
        @_super p,
            asset: _.sample ['ship-fighter.png', 'ship-bomber.png', 'ship-frigate.png', 'ship-carrier.png']
            id: null
            playerId: null
            healh: _.sample [50, 76, 100]
            tile: null
            target: null
            scale: 0.17
            angle: _.sample [10,382,133,98]
            alignmentMarker: new Game.Sprite({asset: 'enemy-marker.png'})

        if Game.state.get('player').ownsShip @
            @p.alignmentMarker.asset 'friendly-marker.png' 

        @on 'touch'
        @on 'inserted'
        @on 'tileChanged'

    step: () ->
        @p.alignmentMarker.p.x = @p.x 
        @p.alignmentMarker.p.y = @p.y

    inserted: () ->
        @stage.insert @p.alignmentMarker

    touch: () ->
        Game.events.trigger 'ship:clicked', @
        console.log 'ship clicked', @

    tileChanged: () ->
        if @p.tile
            @p.x = @p.tile.p.x
            @p.y = @p.tile.p.y

    moveToTile: (tile) ->
        if @p.tile 
            @p.tile.removeEntity @
        @p.tile = tile
        @p.tile.addEntity @
        @trigger 'tileChanged'

    targetShip: (ship) ->
        @p.target = ship

    fireAt: (ship) ->
        # return unless ship.p.alive
        # bullet = new Bullet(@p, ship)


