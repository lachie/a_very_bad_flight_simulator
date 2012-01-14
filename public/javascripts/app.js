(function() {
  var Game, KEYCODE_A, KEYCODE_D, KEYCODE_LEFT, KEYCODE_RIGHT, KEYCODE_SPACE, KEYCODE_UP, KEYCODE_W, Obstacle, Player, Sector, Stats, spriteData, widths;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  console.log("app cawfee");
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
        frames: [6, 7, 8],
        next: true
      }
    }
  };
  console.log("sd", spriteData.frames);
  Player = (function() {
    function Player() {
      this.spriteSheet = new SpriteSheet(spriteData);
      this.anim = new BitmapAnimation(this.spriteSheet);
      this.anim.gotoAndPlay('run');
    }
    Player.prototype.addChildren = function(stage) {
      return stage.addChild(this.anim);
    };
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
    Stats.prototype.update = function() {
      return this.fps.text = Ticker.getMeasuredFPS().toString().substring(0, 4);
    };
    return Stats;
  })();
  Obstacle = (function() {
    function Obstacle(stage, speed) {
      this.speed = speed;
      this.bg = new Shape();
      this.height || (this.height = Math.random() * 150 + 20);
      this.width || (this.width = Math.random() * 50 + 20);
      this.bg.graphics.beginStroke("#444").beginFill(Graphics.getHSL(Math.random() * 360, 100, 50)).drawRect(600, 350 - this.height, this.width, this.height);
      stage.addChild(this.bg);
    }
    Obstacle.prototype.update = function() {
      return this.bg.x -= this.speed;
    };
    return Obstacle;
  })();
  Sector = (function() {
    function Sector(stage) {
      this.stage = stage;
      this.objects = [];
      this.max_objects = 10;
      this.sector_count = 0;
      this.base_prob = 0.003;
    }
    Sector.prototype.reset = function() {
      this.objects = [];
      this.stage.clear();
      return this.sector_count += 1;
    };
    Sector.prototype.update = function() {
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
        console.log("Sector generated object");
        obstacle = new Obstacle(this.stage, this.speed());
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
      this.player = new Player;
      this.player.addChildren(this.stage);
      this.sector = new Sector(this.stage);
      this.stats = new Stats(this.stage);
      document.onkeydown = this.handleKeyDown;
      document.onkeyup = this.handleKeyUp;
    }
    Game.prototype.handleKeyDown = function(e) {
      e || (e = window.event);
      switch (e.keyCode) {
        case KEYCODE_SPACE:
          return this.jumpHeld = true;
      }
    };
    Game.prototype.handleKeyUp = function(e) {
      e || (e = window.event);
      switch (e.keyCode) {
        case KEYCODE_SPACE:
          return this.jumpHeld = false;
      }
    };
    Game.prototype.tick = function() {
      this.stage.update();
      this.stats.sectors.text = "Sector " + this.sector.sector_count.toString();
      this.stats.update();
      return this.sector.update();
    };
    return Game;
  })();
  $(function() {
    var canvas, game, stage;
    console.log("app cawfee");
    canvas = document.getElementById("testCanvas");
    console.log("c", canvas);
    stage = new Stage(canvas);
    game = new Game(stage);
    Ticker.setFPS(60);
    return Ticker.addListener(game);
  });
}).call(this);
