PewNet = {};
PewNet.config = {
    socketPath: "ws://kineticstrike.herokuapp.com/ws",
    channel: "game"
};

var socket = new Phoenix.Socket(PewNet.config.socketPath);

PewNet.requestGame = function(username, callback) {
    socket.join(PewNet.config.channel, "lobby", {username: username}, function(channel) {

        var player;

        channel.on("player:created", function(message) {
            player = message;
            console.log("player ID = " + player.id);
        });

        channel.on("game:created", function(message) {
            callback(message.id, player, message.players);
            channel.leave();
        });
    });
};

PewNet.joinGame = function(player, gameId, eventReceiver, callback) {
    socket.join(PewNet.config.channel, gameId, player, function(channel) {
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

$(document).ready(function() {
  var form, game;
  game = $("#game");
  form = $("#lobbyform");
  $(".loading-message").hide();
  game.hide();
  return form.on("submit", function(e) {
    var el, username, _i, _len, _ref;
    e.preventDefault();
    username = form.get(0).username.value;
    if (username.length !== 0) {
      $(".loading-message").show();
      _ref = form.get(0).elements;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        el = _ref[_i];
        el.disabled = "disabled";
      }
      return PewNet.requestGame(username, function(gameId, player, players) {
        game.show();
        form.hide();
        window.Game = new Phaser.Game(800, 600, Phaser.AUTO, 'game', {
          preload: function() {
            Game.load.image('ship', 'images/ship-spark.png');
            return Game.load.image('hex', 'images/hexagon.png');
          },
          create: function() {
            var grid, ship;
            grid = new HexGrid(10, 10);
            return ship = Game.add.sprite(200, 200, 'ship');
          }
        });
        return PewNet.joinGame(player, gameId, {
          shipMove: function() {
            return console.log(arguments);
          }
        }, function(messager) {
          return window.dg = messager;
        });
      });
    }
  });
});

var HexGrid;

HexGrid = (function() {
  function HexGrid(sizeX, sizeY) {
    var tile, x, y, _i, _j;
    for (x = _i = -sizeX; -sizeX <= sizeX ? _i <= sizeX : _i >= sizeX; x = -sizeX <= sizeX ? ++_i : --_i) {
      for (y = _j = -sizeY; -sizeY <= sizeY ? _j <= sizeY : _j >= sizeY; y = -sizeY <= sizeY ? ++_j : --_j) {
        if (!((Helpers.isEven(x) && Helpers.isEven(y)) || (Helpers.isOdd(x) && Helpers.isOdd(y)))) {
          tile = new HexTile(x, y);
          this.tiles.push(tile);
        }
      }
    }
  }

  HexGrid.prototype.tiles = [];

  return HexGrid;

})();

var HexTile;

HexTile = (function() {
  function HexTile(x, y) {
    this.x = x;
    this.y = y;
    this.sprite = Game.add.sprite(this.x * 120, this.y * 69, 'hex');
    this.sprite.anchor.set(0.5);
  }

  HexTile.prototype.sprite = null;

  HexTile.prototype.x = null;

  HexTile.prototype.y = null;

  return HexTile;

})();

var Helpers;

Helpers = {
  isEven: function(num) {
    return num % 2 === 0;
  },
  isOdd: function(num) {
    return !(num % 2 === 0);
  }
};
