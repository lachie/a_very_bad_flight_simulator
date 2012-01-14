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
    }
    Stats.prototype.update = function() {
      return this.fps.text = Ticker.getMeasuredFPS().toString().substring(0, 4);
    };
    return Stats;
  })();
  Obstacle = (function() {
    function Obstacle(stage) {
      this.bg = new Shape();
      this.height || (this.height = Math.random() * 50 + 20);
      this.width || (this.width = Math.random() * 50 + 20);
      this.bg.graphics.beginStroke("#444").beginFill("#DDAA33").drawRect(600, 350 - this.height, this.width, this.height);
      stage.addChild(this.bg);
    }
    Obstacle.prototype.update = function() {
      return this.bg.x -= 0.5;
    };
    return Obstacle;
  })();
  Sector = (function() {
    function Sector(stage) {
      this.stage = stage;
      this.objects = [];
    }
    Sector.prototype.reset = function() {
      return this.objects = [];
    };
    Sector.prototype.update = function() {
      var i, object, _len, _ref, _results;
      this.generate();
      _ref = this.objects;
      _results = [];
      for (i = 0, _len = _ref.length; i < _len; i++) {
        object = _ref[i];
        _results.push(object.update());
      }
      return _results;
    };
    Sector.prototype.generate = function() {
      if (Math.random() < 0.006) {
        console.log("Sector generated object");
        return this.objects.push(new Obstacle(this.stage));
      }
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
      var scoreField;
      this.stage = stage;
      this.handleKeyUp = __bind(this.handleKeyUp, this);
      this.handleKeyDown = __bind(this.handleKeyDown, this);
      scoreField = new Text("Hello again", "bold 12px Arial", "#FF0000");
      scoreField.x = 300;
      scoreField.y = 300;
      scoreField.text = "Hello cruel World";
      this.stage.addChild(scoreField);
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
