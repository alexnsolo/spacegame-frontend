Game = new Phaser.Game(
    800, 600, Phaser.AUTO, 'game'
    {
        preload: () ->
            Game.load.image('ship', 'images/ship-spark.png')
            Game.load.image('hex', 'images/hexagon.png')
        create: () ->
            Game.add.sprite(200, 200, 'ship')

            # hex grid ish
            for y in [0..10]
                for x in [0..10]
                    return if x % 2 is not 0
                    xOffset = x * 158
                    yOffset = y * 100
                    
                    hex = Game.add.sprite(xOffset, yOffset, 'hex')
                    hex.anchor.set(0.5)
    }
)