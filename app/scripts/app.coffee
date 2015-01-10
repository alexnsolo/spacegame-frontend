Game = new Phaser.Game(
    800 
    600
    Phaser.AUTO
    'game'
    { 
        preload: () ->
            Game.load.image('ship', 'images/mock-ship.png')
        create: () ->
            Game.add.sprite(200, 200, 'ship')
    }
)