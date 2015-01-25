Game.Sprite.extend 'Ship',
    init: (p) ->
        @_super p,
            asset: _.sample ['ship-fighter.png', 'ship-bomber.png', 'ship-frigate.png', 'ship-carrier.png']
            shipId: null
            playerId: null
            health: 100
            tile: null
            target: null
            scale: 0.17
            z: 100
            collisionMask: Game.SPRITE_DEFAULT
            angle: _.sample [10,382,133,98]
            alignmentMarker: new Game.Sprite
                asset: 'enemy-marker.png'
                collisionMask: Game.SPRITE_UI
                z: 1
            healthIndicator: new Game.UI.Text
                label: '0'
                color: 'rgb(0,255,0)'
                collisionMask: Game.SPRITE_UI
                z: 1
            weaponsCooldown: _.sample [1.2, 2.3, 3.4]
            _weaponsCooldownLeft: 0

        if Game.state.get('player').ownsShip @
            @p.alignmentMarker.asset 'friendly-marker.png' 

        @on 'touch'
        @on 'inserted'
        @on 'tileChanged'

    step: (dt) ->
        @p.alignmentMarker.p.x = @p.x 
        @p.alignmentMarker.p.y = @p.y
        @p.healthIndicator.p.x = @p.x
        @p.healthIndicator.p.y = @p.y + 56
        @p.healthIndicator.p.label = new String(@p.health)

        @p._weaponsCooldownLeft -= dt
        if @p._weaponsCooldownLeft <= 0
            @p._weaponsCooldownLeft = @p.weaponsCooldown 
            @fireAt(@p.target) if @p.target

    inserted: () ->
        @stage.insert @p.alignmentMarker
        @stage.insert @p.healthIndicator

    touch: () ->
        console.log 'ship clicked', @
        # Game.events.trigger 'ship:clicked', @

    tileChanged: () ->
        if @p.tile
            @p.x = @p.tile.p.x
            @p.y = @p.tile.p.y

    moveToTile: (tile) ->
        return unless tile.acceptsEntity @

        if @p.tile 
            @p.tile.removeEntity @

        @p.tile = tile
        @p.tile.addEntity @

        @trigger 'tileChanged'

    targetShip: (ship) ->
        @p.target = ship

    fireAt: (ship) ->
        # console.log 'firing at ship'