(function() {
  var CEILING_LEVEL, FLOOR_LEVEL, FPS, Game, Gravity, HEIGHT, INTERVAL, JetpackThrust, KEYCODE_A, KEYCODE_D, KEYCODE_LEFT, KEYCODE_RIGHT, KEYCODE_SPACE, KEYCODE_UP, KEYCODE_W, Obstacle, Player, Sector, Stats, WIDTH, spriteData, widths;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  console.log("app cawfee");
  FPS = 60;
  INTERVAL = 1 / FPS * 1000;
  console.log(INTERVAL);
  WIDTH = 600;
  HEIGHT = 400;
  FLOOR_LEVEL = HEIGHT - 100;
  CEILING_LEVEL = 10;
  Gravity = 175;
  JetpackThrust = -300;
  widths = [29, 32, 29, 31, 31];
  spriteData = {
    images: ["images/mario.png"],
    frames: {
      width: 30,
      height: 16,
      count: 10
    },
    animations: {
      run: {
        frames: [6, 6, 6, 7, 7, 7, 8, 8, 8],
        next: true
      }
    }
  };
  console.log("sd", spriteData.frames);
  Player = (function() {
    __extends(Player, Container);
    function Player(game) {
      this.game = game;
      Container.prototype.initialize.apply(this);
      this.spriteSheet = new SpriteSheet(spriteData);
      this.anim = new BitmapAnimation(this.spriteSheet);
      this.anim.gotoAndPlay('run');
      this.v = 0;
      this.y = 0;
      this.addChild(this.anim);
    }
    Player.prototype.tick = function() {
      var accel, dt;
      dt = INTERVAL / 1000;
      if (this.game.jumpHeld) {
        accel = JetpackThrust;
      } else {
        accel = Gravity;
      }
      this.v += accel * dt;
      this.y += this.v * dt;
      if (this.y > FLOOR_LEVEL) {
        this.y = FLOOR_LEVEL;
        this.bumpedFloor();
        this.v = 0;
      }
      if (this.y < CEILING_LEVEL) {
        this.y = CEILING_LEVEL;
        this.bumpedCeiling();
        return this.v = 0;
      }
    };
    Player.prototype.bumpedCeiling = function() {};
    Player.prototype.bumpedFloor = function() {};
    return Player;
  })();
  Stats = (function() {
    function Stats(stage) {
      this.fps = new Text("Hello again", "bold 12px Arial", "#00FF55");
      this.fps.x = 10;
      this.fps.y = 20;
      this.fps.text = "";
      stage.addChild(this.fps);
      this.sectors = new Text("Hello again", "bold 12px Arial", "#FF0055");
      this.sectors.x = 100;
      this.sectors.y = 20;
      this.sectors.text = "Sectors";
      stage.addChild(this.sectors);
    }
    Stats.prototype.tick = function() {
      return this.fps.text = Ticker.getMeasuredFPS().toString().substring(0, 2);
    };
    return Stats;
  })();
  Obstacle = (function() {
    function Obstacle(sector, speed) {
      this.speed = speed;
      this.bg = new Shape();
      this.height || (this.height = Math.random() * 150 + 20);
      this.width || (this.width = Math.random() * 50 + 20);
      this.bg.graphics.beginStroke("#000").beginFill(Graphics.getHSL(Math.random() * 360, 100, 50)).drawRect(600, 350 - this.height, this.width, this.height);
      sector.addChild(this.bg);
    }
    Obstacle.prototype.update = function() {
      return this.bg.x -= this.speed;
    };
    return Obstacle;
  })();
  Sector = (function() {
    __extends(Sector, Container);
    function Sector(stage) {
      this.stage = stage;
      Container.prototype.initialize.apply(this);
      this.objects = [];
      this.max_objects = 3;
      this.sector_count = 0;
      this.base_prob = 0.003;
      this.stage.addChild(this);
    }
    Sector.prototype.reset = function() {
      this.removeAllChildren();
      this.objects = [];
      return this.sector_count += 1;
    };
    Sector.prototype.tick = function() {
      var i, object, _len, _ref, _results;
      if (this.objects.length >= this.max_objects) {
        this.reset();
      }
      if (this.wait > 0) {
        this.wait -= 1;
      } else {
        this.generate();
      }
      _ref = this.objects;
      _results = [];
      for (i = 0, _len = _ref.length; i < _len; i++) {
        object = _ref[i];
        _results.push(object.update());
      }
      return _results;
    };
    Sector.prototype.generate = function() {
      var obstacle;
      if (Math.random() < this.prob() && this.objects.length < this.max_objects) {
        obstacle = new Obstacle(this, this.speed());
        this.objects.push(obstacle);
        this.wait = obstacle.width + 50;
        return;
      }
      return this.wait = 0;
    };
    Sector.prototype.prob = function() {
      return this.base_prob + this.sector_count * 0.01;
    };
    Sector.prototype.speed = function() {
      return 0.5 + this.sector_count * 0.5;
    };
    return Sector;
  })();
  KEYCODE_SPACE = 32;
  KEYCODE_UP = 38;
  KEYCODE_LEFT = 37;
  KEYCODE_RIGHT = 39;
  KEYCODE_W = 87;
  KEYCODE_A = 65;
  KEYCODE_D = 68;
  Game = (function() {
    function Game(stage) {
      this.stage = stage;
      this.handleKeyUp = __bind(this.handleKeyUp, this);
      this.handleKeyDown = __bind(this.handleKeyDown, this);
      this.player = new Player(this);
      this.stage.addChild(this.player);
      this.jumpHeld = false;
      $(document).keydown(this.handleKeyDown);
      $(document).keyup(this.handleKeyUp);
      this.sector = new Sector(this.stage);
      this.stats = new Stats(this.stage);
    }
    Game.prototype.handleKeyDown = function(e) {
      e.stopPropagation();
      switch (e.keyCode) {
        case KEYCODE_SPACE:
          return this.jumpHeld = true;
      }
    };
    Game.prototype.handleKeyUp = function(e) {
      e.stopPropagation();
      switch (e.keyCode) {
        case KEYCODE_SPACE:
          return this.jumpHeld = false;
      }
    };
    Game.prototype.tick = function() {
      this.stage.update();
      this.stats.sectors.text = "Sector " + this.sector.sector_count.toString();
      this.stats.tick();
      return this.sector.tick();
    };
    return Game;
  })();
  $(function() {
    var canvas, game, stage;
    canvas = $('#testCanvas');
    canvas.attr('width', WIDTH);
    canvas.attr('height', HEIGHT);
    stage = new Stage(canvas[0]);
    game = new Game(stage);
    Ticker.setInterval(INTERVAL);
    return Ticker.addListener(game);
  });
}).call(this);
