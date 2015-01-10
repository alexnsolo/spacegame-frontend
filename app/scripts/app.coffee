Game = new Phaser.Game(
    800, 600, Phaser.AUTO, 'game'
    {
        preload: () ->
            Game.load.image('ship-fighter', 'images/ship-fighter.png')
            Game.load.image('ship-bomber', 'images/ship-bomber.png')
            Game.load.image('ship-carrier', 'images/ship-carrier.png')
            Game.load.image('ship-frigate', 'images/ship-frigate.png')
            Game.load.image('bullet', 'images/bullet.png')
            Game.load.image('hex', 'images/hexagon.png')
            Game.load.image('explosion', 'images/explosion.png')

        create: () ->
            grid = new HexGrid(10, 10)

            ship1 = new Ship(1, grid.tiles[7])
            ship2 = new Ship(2, grid.tiles[19])
            ship3 = new Ship(3, grid.tiles[23])

            ship1.targetShip(ship2)
            ship2.targetShip(ship3)

            setTimeout () =>
                ship1.moveToTile(grid.tiles[8])
            , 3000

            setTimeout () =>
                ship2.moveToTile(grid.tiles[20])
            , 2000
    }
)