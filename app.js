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
        return window.Game = new Phaser.Game(800, 600, Phaser.AUTO, 'game', {
          preload: function() {
            Game.load.image('ship-fighter', 'images/ship-fighter.png');
            Game.load.image('ship-bomber', 'images/ship-bomber.png');
            Game.load.image('ship-carrier', 'images/ship-carrier.png');
            Game.load.image('ship-frigate', 'images/ship-frigate.png');
            Game.load.image('bullet', 'images/bullet.png');
            Game.load.image('hex', 'images/hexagon.png');
            return Game.load.image('explosion', 'images/explosion.png');
          },
          create: function() {
            var hexGrid, ship1, ship2;
            hexGrid = new HexGrid(10, 10);
            ship1 = new Ship(1, hexGrid.tiles[7]);
            ship2 = new Ship(2, hexGrid.tiles[23]);
            ship1.targetShip(ship2);
            ship2.targetShip(ship1);
            setTimeout((function(_this) {
              return function() {
                return ship1.moveToTile(hexGrid.tiles[8]);
              };
            })(this), 3000);
            setTimeout((function(_this) {
              return function() {
                return ship2.moveToTile(hexGrid.tiles[22]);
              };
            })(this), 2000);
            return PewNet.joinGame(player, gameId, {
              shipCreate: function(ship) {
                var tile;
                console.log('server: shipCreate', arguments);
                tile = hexGrid.findTileByCoords(ship.x, ship.y);
                if (!tile) {
                  console.log('no tile! fuck');
                }
                return new Ship(ship.id, tile);
              },
              shipMove: function(id, coordinates) {
                return console.log('server: shipMove', arguments);
              }
            }, function(messager) {
              return window.dg = messager;
            });
          }
        });
      });
    }
  });
});

var Bullet,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Bullet = (function() {
  Bullet.sprite = null;

  Bullet.target = null;

  Bullet.damage = null;

  function Bullet(startPos, target) {
    this.onShipCollide = __bind(this.onShipCollide, this);
    this.damage = _.sample([17, 10, 6]);
    this.target = target;
    this.sprite = Game.add.sprite(startPos.x, startPos.y, 'bullet');
    this.sprite.anchor.set(0.5);
    this.sprite.scale = {
      x: 0.4,
      y: 0.4
    };
    Game.physics.arcade.enableBody(this.sprite);
    this.sprite.body.mass = 0;
    this.sprite.update = (function(_this) {
      return function() {
        if (!_this.target.sprite.alive) {
          _this.sprite.kill();
        }
        Game.physics.arcade.moveToObject(_this.sprite, _this.target.sprite.position, 200);
        return Game.physics.arcade.collide(_this.sprite, _this.target.sprite, _this.onShipCollide);
      };
    })(this);
  }

  Bullet.prototype.onShipCollide = function(me, other) {
    other.damage(this.damage);
    return this.sprite.kill();
  };

  return Bullet;

})();

var Explosion;

Explosion = (function() {
  Explosion.prototype.sprite = null;

  function Explosion(position) {
    this.sprite = Game.add.sprite(position.x, position.y, 'explosion');
    this.sprite.anchor.set(0.5);
    this.sprite.scale = {
      x: 0,
      y: 0
    };
    this.sprite.update = (function(_this) {
      return function() {
        _this.sprite.rotation += 0.01;
        _this.sprite.scale.x += 0.05;
        return _this.sprite.scale.y += 0.05;
      };
    })(this);
    setTimeout((function(_this) {
      return function() {
        return _this.sprite.kill();
      };
    })(this), 500);
  }

  return Explosion;

})();

var HexGrid;

HexGrid = (function() {
  HexGrid.prototype.tiles = [];

  function HexGrid(sizeX, sizeY) {
    var tile, x, y, _i, _j;
    for (x = _i = 0; 0 <= sizeX ? _i <= sizeX : _i >= sizeX; x = 0 <= sizeX ? ++_i : --_i) {
      for (y = _j = 0; 0 <= sizeY ? _j <= sizeY : _j >= sizeY; y = 0 <= sizeY ? ++_j : --_j) {
        if (!((Helpers.isEven(x) && Helpers.isEven(y)) || (Helpers.isOdd(x) && Helpers.isOdd(y)))) {
          tile = new HexTile(x, y);
          this.tiles.push(tile);
        }
      }
    }
  }

  HexGrid.prototype.findTileByCoords = function(x, y) {
    return _.find(tiles, function(tile) {
      return tile.x === x && tile.y === y;
    });
  };

  return HexGrid;

})();

var HexTile;

HexTile = (function() {
  function HexTile(x, y) {
    this.coordinates = {
      x: x,
      y: y
    };
    this.sprite = Game.add.sprite(x * 120, y * 69, 'hex');
    this.sprite.anchor.set(0.5);
  }

  HexTile.prototype.sprite = null;

  HexTile.prototype.coordinates = null;

  return HexTile;

})();

var Player;

Player = (function() {
  function Player() {}

  return Player;

})();

var Ship;

Ship = (function() {
  Ship.prototype.id = null;

  Ship.prototype.sprite = null;

  Ship.prototype.tile = null;

  Ship.prototype.target = null;

  function Ship(id, starting_tile) {
    var x, y;
    this.id = id;
    this.tile = starting_tile;
    x = this.tile.sprite.position.x;
    y = this.tile.sprite.position.y;
    this.sprite = Game.add.sprite(x, y, _.sample(['ship-fighter', 'ship-bomber', 'ship-frigate', 'ship-carrier']));
    this.sprite.scale = {
      x: 0.15,
      y: 0.15
    };
    this.sprite.rotation = _.sample([10, 382, 133, 98]);
    this.sprite.anchor.set(0.5);
    this.sprite.health = 50;
    this.sprite.events.onKilled.add((function(_this) {
      return function() {
        return new Explosion(_this.sprite.position);
      };
    })(this));
    Game.physics.arcade.enableBody(this.sprite);
    setInterval((function(_this) {
      return function() {
        if (_this.target && _this.sprite.alive) {
          return _this.fireAt(_this.target);
        }
      };
    })(this), 1000);
  }

  Ship.prototype.moveToTile = function(tile) {
    this.tile = tile;
    this.sprite.position.x = tile.sprite.position.x;
    return this.sprite.position.y = tile.sprite.position.y;
  };

  Ship.prototype.targetShip = function(ship) {
    return this.target = ship;
  };

  Ship.prototype.fireAt = function(ship) {
    var bullet;
    if (!ship.sprite.alive) {
      return;
    }
    return bullet = new Bullet(this.sprite.position, ship);
  };

  return Ship;

})();

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
