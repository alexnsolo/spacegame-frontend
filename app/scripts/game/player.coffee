Game.Sprite.extend 'Player',
    init: (p) ->
        @_super p,
            asset: 'nothing.png'
            x: 500
            y: 250
            cameraSpeed: 175

    step: (delta) ->
        if Game.inputs['up'] 
            @p.y -= delta*@p.cameraSpeed
        if Game.inputs['down'] 
            @p.y += delta*@p.cameraSpeed
        if Game.inputs['left'] 
            @p.x -= delta*@p.cameraSpeed
        if Game.inputs['right'] 
            @p.x += delta*@p.cameraSpeed

