Game.Sprite.extend 'Player',
    init: (p) ->
        @_super p,
            asset: 'nothing.png'
            id: null
            x: 500
            y: 250
            cameraSpeed: 175
            selectedShip: null
            selectionMarker: new Game.Sprite({asset: 'selection-marker.png', hidden: true})
            targetMarker: new Game.Sprite({asset: 'target-marker.png', hidden: true})

        @on 'inserted'
        Game.events.on 'ship:clicked', @, 'shipClicked'
        Game.events.on 'hex:clicked', @, 'hexClicked'


    inserted: () ->
        @stage.insert @p.selectionMarker
        @stage.insert @p.targetMarker

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
            
            if @p.selectedShip.p.target
                @p.targetMarker.show()
                @p.targetMarker.p.x = @p.selectedShip.p.target.p.x 
                @p.targetMarker.p.y = @p.selectedShip.p.target.p.y
            else
                @p.targetMarker.hide()
                
        else
            @p.selectionMarker.hide()
            @p.targetMarker.hide()

    shipClicked: (ship) ->
        if ship is @p.selectedShip
            @p.selectedShip = null
            return

        if @ownsShip ship
            @p.selectedShip = ship
            console.log 'selecting ship', ship
        else
            @p.selectedShip.targetShip ship
            console.log 'targeting ship', ship
            

    hexClicked: (tile) ->
        if @p.selectedShip 
            @p.selectedShip.moveToTile tile
            @p.selectedShip = null

    shipSelected: (ship) ->
        @p.selectedShip = ship

    ownsShip: (ship) ->
        ship.p.playerId is @p.id

