Game = window.Game = Quintus(imagePath: '/images/').include('Sprites, Scenes, 2D, Input, UI, Touch')

window.addEventListener 'load', () ->

    Game.setup 'game', {maximize: true}
    Game.controls()
    Game.touch(Game.SPRITE_ALL)

    Game.preload 'hexagon.png'
    Game.preload 'selection-marker.png'
    Game.preload 'target-marker.png'
    Game.preload 'enemy-marker.png'
    Game.preload 'friendly-marker.png'
    Game.preload 'nothing.png'
    Game.preload 'bullet.png'
    Game.preload 'ship-fighter.png'
    Game.preload 'ship-bomber.png'
    Game.preload 'ship-frigate.png'
    Game.preload 'ship-carrier.png'
    Game.preload -> Game.stageScene('main')

    Game.events = new Game.Evented()
    Game.server = null

    Game.scene 'main', (stage) ->
        username = ''
        # username = 'civilframe' + Date.now()
        while username.length is 0
            username = window.prompt("Username:") or ''

        lobbyText = new Game.UI.Text
            label: 'Waiting for opponent...'
            color: 'rgb(255,255,255)'
            x: 500
            y: 100

        stage.insert lobbyText

        PewNet.requestGame username, (gameId, player, players) ->
            playerEntity = new Game.Player {id: player.id}
            stage.insert playerEntity
            Game.state.set 'player', playerEntity
            stage.add('viewport').follow(playerEntity)

            stage.remove lobbyText

            hexGrid = null

            serverEvents = 
                shipCreated: (ship) ->
                    shipEntity = new Game.Ship {id: ship.id, playerId: ship.player.id}
                    tile = hexGrid.findTileByCoords ship.x, ship.y
                    console.error 'tile not found for ship:create' unless tile
                    shipEntity.moveToTile tile
                    stage.insert shipEntity

                shipMoved: (id, coordinates) ->
                    console.debug 'shipMoved', id, coordinates

            PewNet.joinGame player, gameId, serverEvents, (messenger) -> 
                Game.server = messenger
                hexGrid = new Game.HexGrid {sizeX: 10, sizeY: 10}
                stage.insert hexGrid

        # player = new Game.Player {id: 1}
        # stage.insert player
        # Game.state.set 'player', player

        # ship = new Game.Ship {id: 1, playerId: 1}
        # ship.moveToTile hexGrid.p.tiles[19]
        # stage.insert ship

        # ship = new Game.Ship {id: 2, playerId: 3}
        # ship.moveToTile hexGrid.p.tiles[7]
        # stage.insert ship

        # stage.add('viewport').follow(player)
