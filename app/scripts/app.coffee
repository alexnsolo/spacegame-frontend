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
                            Game.load.image('ship', 'images/ship-spark.png')
                            Game.load.image('hex', 'images/hexagon.png')

                        create: () ->

                            grid = new HexGrid(10, 10)
                            ship = Game.add.sprite(200, 200, 'ship')
                    }
                )
                PewNet.joinGame player, gameId, {
                    shipMove: () ->
                        console.log arguments
                }, (messager) ->
                    window.dg = messager
