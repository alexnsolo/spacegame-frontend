Game.Sprite.extend 'Player',
    init: (p) ->
        @_super p,
            asset: 'nothing.png'
            id: null
            x: 500
            y: 250
            cameraSpeed: 175
            selectedShip: null
            selectionMarker: new Game.Sprite({asset: 'selection.png', hidden: true})

        @on 'inserted'
        Game.events.on 'ship:clicked', @, 'shipClicked'
        Game.events.on 'hex:clicked', @, 'hexClicked'


    inserted: () ->
        @stage.insert @p.selectionMarker
        
    step: (delta) ->
        if Game.inputs['up'] 
            @p.y -= delta*@p.cameraSpeed
        if Game.inputs['down'] 
            @p.y += delta*@p.cameraSpeed
        if Game.inputs['left'] 
            @p.x -= delta*@p.cameraSpeed
        if Game.inputs['right'] 
            @p.x += delta*@p.cameraSpeed

        if @p.selectedShip
            @p.selectionMarker.show()
            @p.selectionMarker.p.x = @p.selectedShip.p.x 
            @p.selectionMarker.p.y = @p.selectedShip.p.y
        else
            @p.selectionMarker.hide()

    shipClicked: (ship) ->
        if not @p.selectedShip and @ownsShip ship
            @p.selectedShip = ship
            console.log 'selecting ship', ship

    hexClicked: (tile) ->
        if @p.selectedShip 
            @p.selectedShip.moveToTile tile
            @p.selectedShip = null

    shipSelected: (ship) ->
        @p.selectedShip = ship

    ownsShip: (ship) ->
        ship.p.playerId is @p.id

