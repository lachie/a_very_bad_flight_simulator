(function() {
  var Game, Player, spriteData, widths;
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
  Game = (function() {
    function Game(stage) {
      var scoreField;
      this.stage = stage;
      scoreField = new Text("Hello again", "bold 12px Arial", "#FF0000");
      scoreField.x = 300;
      scoreField.y = 300;
      scoreField.text = "Hello cruel World";
      this.stage.addChild(scoreField);
      this.player = new Player;
      this.player.addChildren(this.stage);
    }
    Game.prototype.tick = function() {
      return this.stage.update();
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
    Ticker.setFPS(10);
    return Ticker.addListener(game);
  });
}).call(this);
