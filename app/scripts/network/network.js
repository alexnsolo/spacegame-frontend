PewNet = {};
PewNet.config = {
    socketPath: "ws://kineticstrike.herokuapp.com/ws",
    channel: "game"
};

var socket = new Phoenix.Socket(PewNet.config.socketPath);

PewNet.requestGame = function(username, callback) {
    socket.join(PewNet.config.channel, "lobby", {username: username}, function(channel) {

        var playerId;

        channel.on("player:created", function(message) {
            playerId = message.id;
            console.log("player ID = " + playerId);
        });

        channel.on("game:created", function(message) {
            callback(message.id, message.players);
            channel.leave();
        });
    });
};

PewNet.joinGame = function(gameId, eventReceiver, callback) {
    socket.join(PewNet.config.channel, gameId, function(channel) {
        channel.on("ship:move", function(message) {
            eventReceiver.shipMove(message.shipId, message.coordinates);
        });
        channel.on("ship:targeted", function(message) {
            eventReceiver.shipTarget(message.shipId, message.targetShipId);
        });
        channel.on("ship:create", function(message) {
            eventReceiver.shipCreate(message.ship);
        });
        channel.on("ship:destroy", function(message) {
            eventReceiver.shipDestroy(message.shipId);
        });
        channel.on("game:end", function(message) {
            eventReceiver.gameOver(message);
            channel.leave();
        });

        callback({
            moveShip: function(id, coordinates) {
                    channel.send("ship:move", {
                        shipId: id,
                        coordinates: coordinates
                    });
                },
            targetShip: function(id, targetShipId) {
                    channel.send("ship:target", {
                        shipId: id,
                        targetShipId: targetShipId
                    });
                }
        });
    });
};
