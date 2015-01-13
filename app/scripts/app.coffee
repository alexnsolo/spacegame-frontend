Game = window.Game = Quintus(imagePath: '/images/').include('Sprites, Scenes, 2D, Input, UI, Touch')

window.addEventListener 'load', () ->

    Game.setup 'game', {maximize: true}
    Game.controls()
    Game.touch(Game.SPRITE_ALL)

    Game.events = new Game.Evented()

    Game.scene 'main', (stage) ->
        hexGrid = new Game.HexGrid {sizeX: 10, sizeY: 10}
        stage.insert hexGrid

        player = new Game.Player {id: 1}
        stage.insert player
        Game.state.set 'player', player

        ship = new Game.Ship {id: 1, playerId: 1}
        ship.moveToTile hexGrid.p.tiles[19]
        stage.insert ship

        ship = new Game.Ship {id: 2, playerId: 3}
        ship.moveToTile hexGrid.p.tiles[7]
        stage.insert ship

        stage.add('viewport').follow(player)

    assets = [
        'hexagon.png'
        'selection-marker.png'
        'target-marker.png'
        'enemy-marker.png'
        'friendly-marker.png'
        'nothing.png'
        'bullet.png'
        'ship-fighter.png'
        'ship-bomber.png'
        'ship-frigate.png'
        'ship-carrier.png'
    ]

    Game.load assets, () ->
        Game.stageScene('main')

