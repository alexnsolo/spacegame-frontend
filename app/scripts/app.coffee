Game = window.Game = Quintus(imagePath: '/images/').include('Sprites, Scenes, 2D, Input, UI')

window.addEventListener 'load', () ->

    Game.setup 'game', {maximize: true}
    Game.controls()

    Game.scene 'menu', (stage) ->
        hexGrid = new Game.HexGrid {sizeX: 10, sizeY: 10}
        stage.insert hexGrid

        ship = new Game.Ship {tile: hexGrid.p.tiles[19]}
        stage.insert ship

        player = new Game.Player()
        stage.insert player

        stage.add('viewport').follow(player)

    assets = [
        'hexagon.png'
        'nothing.png'
        'bullet.png'
        'ship-fighter.png'
        'ship-bomber.png'
        'ship-frigate.png'
        'ship-carrier.png'
    ]

    Game.load assets, () ->
        Game.stageScene('menu')

