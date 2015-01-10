class Ship
    id: null
    sprite: null
    tile: null
    target: null

    constructor: (id, starting_tile) ->
        @id = id
        @tile = starting_tile
        x = @tile.sprite.position.x
        y = @tile.sprite.position.y

        @sprite = Game.add.sprite(x, y, _.sample(['ship-fighter', 'ship-bomber', 'ship-frigate', 'ship-carrier']))
        @sprite.scale = {x:0.15, y: 0.15}
        @sprite.rotation = _.sample([10,382,133,98])
        @sprite.anchor.set(0.5)
        @sprite.health = 50

        @sprite.events.onKilled.add () =>
            new Explosion(@sprite.position)

        Game.physics.arcade.enableBody(@sprite)

        setInterval () =>
            if @target and @sprite.alive
                @fireAt(@target)
        , 1000

    moveToTile: (tile) ->
        @tile = tile
        @sprite.position.x = tile.sprite.position.x
        @sprite.position.y = tile.sprite.position.y

    targetShip: (ship) ->
        @target = ship

    fireAt: (ship) ->
        return unless ship.sprite.alive
        bullet = new Bullet(@sprite.position, ship)


