Game.Sprite.extend 'HexTile',
    init: (p) ->
        @_super p, 
            asset: 'hexagon.png'
            gridCoordinates: {x: 0, y: 0}
            entities: []

        @on 'touch'
        @on 'inserted'
        

    touch: () ->
        Game.events.trigger 'hex:clicked', @
        console.log 'hex clicked', @

    inserted: () ->
        coordLabel = new Game.UI.Text
            label: 'X' + @p.gridCoordinates.x + '  Y' + @p.gridCoordinates.y,
            color: 'rgba(255,255,255,0.5)',
            x: 0,
            y: 0

        @stage.insert coordLabel, @

    acceptsEntity: (entity) ->
        return @p.entities.length is 0

    addEntity: (entity) ->
        return if @hasEntity entity
        @p.entities.push(entity)

    removeEntity: (entity) ->
        return unless @hasEntity entity
        _.remove @p.entities, entity

    hasEntity: (entity) ->
        _.contains @p.entities, entity
