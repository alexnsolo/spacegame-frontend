$(document).ready () ->
    game = $("#game")
    form = $("#lobbyform")
    $(".loading-message").hide()
    game.hide()
    form.on "submit", (e) ->
        e.preventDefault()
        username = form.get(0).username.value
        if username.length isnt 0
            $(".loading-message").show()
            for el in form.get(0).elements
                el.disabled = "disabled"
            PewNet.requestGame username, (gameId, player, players) ->
                game.show()
                form.hide()

                window.Game = new Phaser.Game(
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
                            hexGrid = new HexGrid(10, 10)

                            ship1 = new Ship(1, hexGrid.tiles[7])
                            ship2 = new Ship(2, hexGrid.tiles[23])

                            ship1.targetShip(ship2)
                            ship2.targetShip(ship1)

                            setTimeout () =>
                                ship1.moveToTile(hexGrid.tiles[8])
                            , 3000

                            setTimeout () =>
                                ship2.moveToTile(hexGrid.tiles[22])
                            , 2000

                            PewNet.joinGame player, gameId, {
                                shipCreate: (ship) ->
                                    console.log 'server: shipCreate', arguments
                                    tile = hexGrid.findTileByCoords(ship.x, ship.y)
                                    console.log 'no tile! fuck' unless tile
                                    new Ship(ship.id, tile)

                                shipMove: (id, coordinates) ->
                                    console.log 'server: shipMove', arguments

                            }, (messager) ->
                                window.dg = messager
                    }
                )
                
