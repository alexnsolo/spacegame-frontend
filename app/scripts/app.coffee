document.addEventListener "DOMContentLoaded", () ->
    document.getElementById("game").style.visibility = "hidden"
    f = document.getElementById("lobbyform")
    f.addEventListener "submit", (e) ->
        e.preventDefault()
        for el in f.elements
            el.disabled = "disabled"
        PewNet.requestGame f.username.value, (id, players) ->
            document.getElementById("game").style.visibility = "visible"
            f.style.display = "none"
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
