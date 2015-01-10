class Bullet
    @sprite: null
    @target: null
    @damage: null

    constructor: (startPos, target) ->
        @damage = _.sample([17, 10, 6])
        @target = target

        @sprite = Game.add.sprite(startPos.x, startPos.y, 'bullet')
        @sprite.anchor.set(0.5)
        @sprite.scale = {x:0.4, y: 0.4}

        Game.physics.arcade.enableBody(@sprite)
        @sprite.body.mass = 0
       
        @sprite.update = () =>
            @sprite.kill() unless @target.sprite.alive

            Game.physics.arcade.moveToObject(@sprite, @target.sprite.position, 200)
            Game.physics.arcade.collide(@sprite, @target.sprite, @onShipCollide)

    onShipCollide: (me, other) =>
        other.damage(@damage)
        @sprite.kill()




    

