(function() {
  var BUILDING_DENSITY_FACTOR, CEILING_LEVEL, Collider, FLOOR_LEVEL, FPS, GRASS_SPEED, GRASS_WIDTH, Game, GameState, Grass, Gravity, HEIGHT, INTERVAL, InitialLevelSpeed, JetpackThrust, KEYCODE_A, KEYCODE_D, KEYCODE_ESC, KEYCODE_LEFT, KEYCODE_RIGHT, KEYCODE_SPACE, KEYCODE_UP, KEYCODE_W, Logo, Obstacle, PLAYER_X_OFFSET, Player, SKY_SPEED, SKY_WIDTH, Sector, Sky, Stats, WIDTH, Word, building_dimensions, count, frames, height, i, num, offset, sparklesFrameData, spriteData, width, widths, words;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __slice = Array.prototype.slice, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  FPS = 60;
  INTERVAL = 1 / FPS * 1000;
  WIDTH = 600;
  HEIGHT = 400;
  FLOOR_LEVEL = HEIGHT - 3 - 32;
  CEILING_LEVEL = 10;
  Gravity = 275;
  JetpackThrust = -800;
  SKY_WIDTH = 900;
  SKY_SPEED = 0.2;
  GRASS_WIDTH = 600;
  GRASS_SPEED = 8.0;
  BUILDING_DENSITY_FACTOR = 0.005;
  PLAYER_X_OFFSET = 100;
  widths = [29, 32, 29, 31, 31];
  building_dimensions = [[190, 265], [194, 259], [220, 220], [253, 204], [181, 132], [267, 200]];
  words = "FISH CAT HAT POO BUM RED BLUE        ENNUI DEPRESSION MORTGAGE        RUMPYPUMPY WHISKEY        ROBUST BUXOM WANTON INTERCOURSE";
  words = words.split(/\s+/);
  spriteData = {
    images: ["images/mario.png", "images/mariosplat.png"],
    animations: {
      run: {
        frames: [6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8],
        next: true
      },
      fly: {
        frames: [5],
        next: true
      },
      splat: {
        frames: [12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17],
        next: false
      }
    }
  };
  count = 0;
  spriteData.frames = [];
  width = 30;
  height = 16;
  offset = 0;
  for (i = 0; i < 12; i++) {
    spriteData.frames.push([offset, 0, width, height, 0]);
    offset += width;
    count += 1;
  }
  width = 32;
  height = 32;
  offset = 0;
  for (i = 0; i < 8; i++) {
    spriteData.frames.push([0, offset, width, height, 1]);
    offset += height;
    count += 1;
  }
  frames = (function() {
    var _results;
    _results = [];
    for (i = 0; i < 8; i++) {
      num = i + 12;
      _results.push([num, num, num, num]);
    }
    return _results;
  })();
  spriteData.animations.splat.frames = _.flatten(frames);
  sparklesFrameData = {
    images: ["images/sparkle_21x23.png"],
    frames: {
      width: 21,
      height: 23,
      regX: 10,
      regY: 11
    }
  };
  Player = (function() {
    __extends(Player, Container);
    function Player(game) {
      this.game = game;
      Container.prototype.initialize.apply(this);
      this.sparkles = [];
      this.makeAnim();
      this.makeSparkles();
      this.drawFlame();
      this.v = 0;
      this.y = 0;
      this.x = PLAYER_X_OFFSET;
      this.scaleX = 2;
      this.scaleY = 2;
      this.width = 30;
      this.height = 16;
      this.addChild(this.flame);
      this.addChild(this.anim);
      this.score = 0;
      this.ticks = 0;
    }
    Player.prototype.finishedDying = function() {
      return this.game.fire('dead');
    };
    Player.prototype.addScore = function(score) {
      this.score += score;
      return this.addSparkle();
    };
    Player.prototype.makeAnim = function() {
      var player;
      this.spriteSheet = new SpriteSheet(spriteData);
      this.anim = new BitmapAnimation(this.spriteSheet);
      this.anim.player = this;
      this.anim.gotoAndPlay('run');
      player = this;
      return this.anim.onAnimationEnd = function(anim, anim) {
        if (anim === 'splat') {
          return player.finishedDying();
        }
      };
    };
    Player.prototype.drawFlame = function() {
      var g, o;
      this.flame = new Shape();
      o = this.flame;
      o.scaleX = 2;
      o.scaleY = 2;
      o.rotation = 180;
      o.x = 7;
      o.y = 12;
      o.visible = false;
      g = o.graphics;
      g.clear();
      g.beginFill("#FF0000");
      g.moveTo(2, 0);
      g.lineTo(4, -3);
      g.lineTo(2, -2);
      g.lineTo(0, -5);
      g.lineTo(-2, -2);
      g.lineTo(-4, -3);
      return g.lineTo(-2, -0);
    };
    Player.prototype.makeSparkles = function() {
      return this.bmpAnim = new BitmapAnimation(new SpriteSheet(sparklesFrameData));
    };
    Player.prototype.addSparkle = function() {
      var angle, sparkle, speed, v;
      sparkle = this.bmpAnim.clone();
      sparkle.gotoAndPlay(Math.random() * sparkle.spriteSheet.getNumFrames() | 0);
      speed = .5;
      angle = Math.PI * 2 * Math.random();
      v = (Math.random() - 0.5) * 30 * speed;
      sparkle.vX = Math.cos(angle) * v;
      sparkle.vY = Math.sin(angle) * v;
      sparkle.vS = (Math.random() - 0.5) * 0.2;
      sparkle.vA = -Math.random() * 0.05 - 0.01;
      this.sparkles.push(sparkle);
      return this.addChild(sparkle);
    };
    Player.prototype.fire = function() {
      var args, event;
      event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (this.state === 'die' || this.state === 'dying') {
        return;
      }
      if (this.state !== event) {
        this.state = event;
        switch (this.state) {
          case 'jump':
            return this.anim.gotoAndPlay('fly');
          case 'die':
            this.die();
            return this.anim.gotoAndPlay('splat');
          case 'unjump':
            return this.anim.gotoAndPlay('run');
        }
      }
    };
    Player.prototype.die = function() {
      this.state = 'dying';
      this.game.fire('dying');
      return this.anim.gotoAndPlay('splat');
    };
    Player.prototype.finishedDying = function() {
      return this.game.fire('dead');
    };
    Player.prototype.tick = function() {
      var accel, dt, newSparkles, sparkle, _i, _len, _ref;
      dt = INTERVAL / 1000;
      switch (this.state) {
        case 'jump':
          accel = JetpackThrust;
          this.flame.visible = true;
          break;
        case 'die':
        case 'dying':
          accel = Gravity / 2;
          this.flame.visible = false;
          if (this.y <= 0) {
            this.finishedDying();
          }
          break;
        default:
          accel = Gravity;
          this.flame.visible = false;
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
        this.v = 0;
      }
      newSparkles = [];
      _ref = this.sparkles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        sparkle = _ref[_i];
        sparkle.x += sparkle.vX;
        sparkle.y += sparkle.vY;
        sparkle.alpha += sparkle.vA;
        if (sparkle.alpha <= 0) {
          this.removeChild(sparkle);
        } else {
          newSparkles.push(sparkle);
        }
      }
      return this.sparkles = newSparkles;
    };
    Player.prototype.bumpedCeiling = function() {};
    Player.prototype.bumpedFloor = function() {};
    return Player;
  })();
  Collider = (function() {
    function Collider() {}
    Collider.prototype.collide = function(player, colliders) {
      var collider, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = colliders.length; _i < _len; _i++) {
        collider = colliders[_i];
        if (collider.contains(player)) {
          collider.hit(player);
          break;
        }
      }
      return _results;
    };
    return Collider;
  })();
  Stats = (function() {
    function Stats(stage) {
      this.fps = new Text("Hello again", "bold 12px Arial", "#00FF55");
      this.fps.x = 10;
      this.fps.y = 20;
      this.fps.text = "";
      stage.addChild(this.fps);
      this.score = new Text("", "bold 32px Arial", "#FF0055");
      this.score.x = WIDTH - 250;
      this.score.y = 40;
      this.score.text = "Score";
      stage.addChild(this.score);
    }
    Stats.prototype.tick = function() {
      return this.fps.text = Ticker.getMeasuredFPS().toString().substring(0, 2);
    };
    return Stats;
  })();
  Sky = (function() {
    __extends(Sky, Bitmap);
    function Sky() {
      Bitmap.prototype.initialize.apply(this);
    }
    return Sky;
  })();
  Grass = (function() {
    __extends(Grass, Bitmap);
    function Grass() {
      Bitmap.prototype.initialize.apply(this);
    }
    return Grass;
  })();
  Obstacle = (function() {
    __extends(Obstacle, Bitmap);
    function Obstacle(image, x, y, width, height) {
      this.x = x;
      this.y = y;
      this.width = width;
      this.height = height;
      Bitmap.prototype.initialize.apply(this, [image]);
    }
    Obstacle.prototype.contains = function(t) {
      var x, y, _ref;
      _ref = t.localToLocal(0, 0, this), x = _ref.x, y = _ref.y;
      return x + t.width > 0 && y + t.height > 0;
    };
    Obstacle.prototype.is_collidable = function(p) {
      var x, y, _ref;
      _ref = p.localToLocal(0, 0, this), x = _ref.x, y = _ref.y;
      return x < this.width;
    };
    Obstacle.prototype.hit = function(player) {
      return player.die();
    };
    return Obstacle;
  })();
  Word = (function() {
    __extends(Word, Text);
    function Word(word, x, y) {
      this.x = x;
      this.y = y;
      Text.prototype.initialize.apply(this, ["", "36px Arial", "#F00"]);
      this.textBaseline = 'top';
      this.text = word;
      this.width = this.getMeasuredWidth();
      this.height = this.getMeasuredLineHeight();
      this.y -= this.height;
    }
    Word.prototype.tick = function() {
      if (this.wasHit) {
        return this.color = '#400';
      }
    };
    Word.prototype.contains = function(t) {
      var x, y, _ref;
      _ref = t.localToLocal(0, 0, this), x = _ref.x, y = _ref.y;
      return x + t.width > 0 && y + t.height > -this.height && y < this.height;
    };
    Word.prototype.hit = function(player) {
      player.addScore(100);
      return this.wasHit = true;
    };
    return Word;
  })();
  InitialLevelSpeed = 2.5;
  Sector = (function() {
    __extends(Sector, Container);
    function Sector(game) {
      this.game = game;
      Container.prototype.initialize.apply(this);
      this.speed = InitialLevelSpeed;
      this.colliders = [];
      this.next_building_time = 0;
      this.next_building_jitter = 200;
      this.obstacle();
    }
    Sector.prototype.tick = function() {
      var child, child_count, i, _step;
      if (this.stopped) {
        return;
      }
      this.remove_children();
      if (!this.game.dead) {
        this.generate();
        this.x -= this.speed;
        this.colliders = [];
        child_count = this.getNumChildren();
        for (i = 0, _step = 2; 0 <= child_count ? i < child_count : i > child_count; i += _step) {
          child = this.getChildAt(i);
          if (child.is_collidable(this.game.player)) {
            this.colliders.push(this.getChildAt(i));
            this.colliders.push(this.getChildAt(i + 1));
            return;
          }
        }
      }
    };
    Sector.prototype.generate = function() {
      if (this.next_building_time <= 0) {
        this.obstacle();
      }
      return this.next_building_time -= 1;
    };
    Sector.prototype.obstacle = function() {
      var bitmap, image, x, y, _ref;
      image = Math.floor(Math.random() * building_dimensions.length);
      _ref = building_dimensions[image], width = _ref[0], height = _ref[1];
      x = -this.x + WIDTH;
      y = HEIGHT - height;
      bitmap = new Obstacle("images/buildings/00" + image + ".jpg", x, y, width, height);
      this.addChild(bitmap);
      this.next_building_time = bitmap.width + Math.random() * this.next_building_jitter;
      this.next_building_jitter -= 2.0;
      if (this.next_building_jitter < 30) {
        this.next_building_jitter = 30;
      }
      return this.word(bitmap);
    };
    Sector.prototype.word = function(obstacle) {
      var text, word, x_pos;
      text = words[Math.floor(Math.random() * words.length)];
      x_pos = obstacle.x + (obstacle.width / 2 - 25);
      word = new Word(text, x_pos, obstacle.y);
      return this.addChild(word);
    };
    Sector.prototype.remove_children = function() {
      var abs_x, child;
      if (this.getNumChildren() === 0) {
        return;
      }
      child = this.getChildAt(0);
      abs_x = this.x + child.x + child.width;
      if (abs_x < 0) {
        this.removeChild(child);
        return this.removeChildAt(0);
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
  KEYCODE_ESC = 27;
  GameState = (function() {
    function GameState(stage) {
      this.stage = stage;
      this.handleKeyUp = __bind(this.handleKeyUp, this);
      this.handleKeyDown = __bind(this.handleKeyDown, this);
    }
    GameState.prototype.enter = function() {
      $(document).keyup(this.handleKeyUp);
      return $(document).keydown(this.handleKeyDown);
    };
    GameState.prototype.exit = function() {
      $(document).unbind('keyup', this.handleKeyUp);
      $(document).unbind('keydown', this.handleKeyDown);
      return this.stage.removeAllChildren();
    };
    GameState.prototype.tick = function() {
      return this.stage.update();
    };
    GameState.prototype.changeState = function(state) {
      this.exit();
      Ticker.removeListener(this);
      state.enter();
      return Ticker.addListener(state);
    };
    GameState.prototype.handleKeyDown = function() {
      return console.log("base kd");
    };
    GameState.prototype.handleKeyUp = function() {
      return console.log("base ku");
    };
    return GameState;
  })();
  Logo = (function() {
    __extends(Logo, GameState);
    function Logo(stage, game) {
      this.stage = stage;
      this.game = game;
      this.handleKeyUp = __bind(this.handleKeyUp, this);
      Logo.__super__.constructor.apply(this, arguments);
    }
    Logo.prototype.enter = function() {
      Logo.__super__.enter.apply(this, arguments);
      this.logo = new Bitmap("images/logo.jpg");
      return this.stage.addChild(this.logo);
    };
    Logo.prototype.handleKeyUp = function(e) {
      e.stopPropagation();
      switch (e.keyCode) {
        case KEYCODE_SPACE:
          return this.changeState(this.game);
      }
    };
    return Logo;
  })();
  Game = (function() {
    __extends(Game, GameState);
    function Game(stage) {
      this.stage = stage;
      this.handleKeyUp = __bind(this.handleKeyUp, this);
      this.handleKeyDown = __bind(this.handleKeyDown, this);
      this.collider = new Collider;
      this.state = 'init';
    }
    Game.prototype.enter = function() {
      Game.__super__.enter.apply(this, arguments);
      return this.start_game();
    };
    Game.prototype.fire = function() {
      var args, event;
      event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      switch (event) {
        case 'dead':
          return this.state = 'dead';
        case 'dying':
          return this.state = 'dying';
      }
    };
    Game.prototype.handleKeyDown = function(e) {
      e.stopPropagation();
      e.preventDefault();
      switch (e.keyCode) {
        case KEYCODE_SPACE:
          switch (this.state) {
            case 'running':
              return this.player.fire('jump');
            case 'dead':
              return this.changeState(this);
          }
          break;
        case KEYCODE_ESC:
          this.paused = !this.paused;
          return Ticker.setPaused(this.paused);
      }
    };
    Game.prototype.handleKeyUp = function(e) {
      e.stopPropagation();
      e.preventDefault();
      switch (e.keyCode) {
        case KEYCODE_SPACE:
          return this.player.fire('unjump');
      }
    };
    Game.prototype.tick = function() {
      switch (this.state) {
        case 'dying':
          0;
          break;
        case 'dead':
          if (!this.game_over) {
            this.go = new Bitmap("images/game_over.jpg");
            this.go.x = 130;
            this.go.y = 160;
            this.stage.addChild(this.go);
            this.sector.stopped = true;
            this.game_over = true;
          }
          break;
        default:
          this.check_sky();
          this.check_grass();
          this.collider.collide(this.player, this.sector.colliders);
          this.stats.score.text = "Score: " + this.player.score;
          this.stats.tick();
      }
      return this.stage.update();
    };
    Game.prototype.start_game = function() {
      this.state = 'starting';
      this.game_over = false;
      this.player = new Player(this);
      this.player.score = 0;
      this.sky1 = new Bitmap("images/sky.jpg");
      this.sky2 = new Bitmap("images/sky.jpg");
      this.stage.addChild(this.sky1);
      this.stage.addChild(this.sky2);
      this.sky2.x += SKY_WIDTH;
      this.sector = new Sector(this);
      this.stage.addChild(this.sector);
      this.stage.addChild(this.player);
      this.stats = new Stats(this.stage);
      this.grass1 = new Bitmap("images/grass.png");
      this.grass2 = new Bitmap("images/grass.png");
      this.stage.addChild(this.grass1);
      this.stage.addChild(this.grass2);
      this.grass1.y = HEIGHT - 40;
      this.grass2.y = HEIGHT - 40;
      this.grass2.x += GRASS_WIDTH;
      return this.state = 'running';
    };
    Game.prototype.check_sky = function() {
      this.sky1.x -= SKY_SPEED;
      this.sky2.x -= SKY_SPEED;
      if (this.sky1.x < -SKY_WIDTH) {
        this.sky1.x += SKY_WIDTH * 2;
      }
      if (this.sky2.x < -SKY_WIDTH) {
        return this.sky2.x += SKY_WIDTH * 2;
      }
    };
    Game.prototype.check_grass = function() {
      this.grass1.x -= GRASS_SPEED;
      this.grass2.x -= GRASS_SPEED;
      if (this.grass1.x < -GRASS_WIDTH) {
        this.grass1.x += GRASS_WIDTH * 2;
      }
      if (this.grass2.x < -GRASS_WIDTH) {
        return this.grass2.x += GRASS_WIDTH * 2;
      }
    };
    return Game;
  })();
  $(function() {
    var canvas, game, logo, stage;
    Ticker.setInterval(INTERVAL);
    canvas = $('#testCanvas');
    canvas.attr('width', WIDTH);
    canvas.attr('height', HEIGHT);
    stage = new Stage(canvas[0]);
    game = new Game(stage);
    logo = new Logo(stage, game);
    logo.enter();
    return Ticker.addListener(logo);
  });
}).call(this);
