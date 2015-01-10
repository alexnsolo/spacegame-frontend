class Explosion
    sprite: null

    constructor: (position) ->
        @sprite = Game.add.sprite(position.x, position.y, 'explosion')
        @sprite.anchor.set(0.5)
        @sprite.scale = {x: 0, y: 0}

        @sprite.update = () =>
            @sprite.rotation += 0.01
            @sprite.scale.x += 0.05
            @sprite.scale.y += 0.05

        setTimeout () =>
            @sprite.kill()
        , 500