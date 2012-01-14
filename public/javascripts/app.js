(function() {
  var CEILING_LEVEL, FLOOR_LEVEL, FPS, Game, Gravity, HEIGHT, INTERVAL, JetpackThrust, KEYCODE_A, KEYCODE_D, KEYCODE_LEFT, KEYCODE_RIGHT, KEYCODE_SPACE, KEYCODE_UP, KEYCODE_W, Player, WIDTH, spriteData, widths;
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
        frames: [6, 7, 8],
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
      this.player = new Player(this);
      this.stage.addChild(this.player);
      this.jumpHeld = false;
      $(document).keydown(this.handleKeyDown);
      $(document).keyup(this.handleKeyUp);
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
    Game.prototype.tick = function(dt) {
      return this.stage.update();
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
