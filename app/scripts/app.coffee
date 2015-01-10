Game = new Phaser.Game(
    800, 600, Phaser.AUTO, 'game'
    {
        preload: () ->
            Game.load.image('ship', 'images/ship-spark.png')
            Game.load.image('hex', 'images/hexagon.png')

        create: () ->

            grid = new HexGrid(10, 10)
            ship = Game.add.sprite(200, 200, 'ship')
    }
)