
FPS = 60
INTERVAL = 1 / FPS * 1000


WIDTH=600
HEIGHT=400

FLOOR_LEVEL = HEIGHT - 3 - 32
CEILING_LEVEL = 10

Gravity = 475
JetpackThrust = -800

SKY_WIDTH = 900
SKY_SPEED = 0.2
GRASS_WIDTH = 600
GRASS_SPEED = 4.0

BUILDING_DENSITY_FACTOR = 0.005

# the player
widths = [29,32,29,31,31]

building_dimensions = [
  [190,265]
  [194,259]
  [220,220]
  [253,204]
  [181,132]
]

words = ['FISH', 'CAT', 'HAT', 'POO', 'BUM', 'RED', 'BLUE']

spriteData =
  images: ["images/mario.png","images/mariosplat.png"],
  animations:
    run:
      frames: [6,6,6,7,7,7,7,7,8,8,8]
      next: true

    fly:
      frames: [5] #6,6,7,7,7,8,8]
      next: true

    splat:
      frames: [12,12,13,13,13,14,14,14,15,15,15,15]
      next: false

count = 0
spriteData.frames = []

width = 30
height = 16
offset = 0
for i in [0...12]
  spriteData.frames.push [offset, 0, width, height, 0]
  offset += width
  count += 1

width = 32
height = 32
offset = 0
for i in [0...6]
  spriteData.frames.push [0, offset, width, height, 1]
  offset += height
  count += 1


frames = for i in [0...6]
  num = i + 12
  [ num, num, num, num ]
spriteData.animations.splat.frames = _.flatten frames


class Player extends Container
  constructor: (@game) ->
    Container.prototype.initialize.apply(@)

    @spriteSheet = new SpriteSheet(spriteData)
    @anim = new BitmapAnimation(@spriteSheet)
    @anim.player = @
    @anim.gotoAndPlay 'run'

    player = @

    @anim.onAnimationEnd = (anim, anim) ->
      if anim == 'splat'
        console.log "DEAD!"
        player.dead()

    @flame = new Shape()
    @drawFlame()

    @v = 0
    @y = 0
    @scaleX = 2
    @scaleY = 2

    @width = 60
    @height = 32


    @addChild @flame
    @addChild @anim

    @score = 0

  dead: ->
    @game.fire('dead')

  drawFlame: ->
    o = @flame

    o.scaleX = 2
    o.scaleY = 2
    o.rotation = 180

    o.x = 7
    o.y = 12

    o.visible = false

    g = o.graphics
    g.clear()
    g.beginFill("#FF0000")

    g.moveTo(2, 0);   # ship
    g.lineTo(4, -3);  # rpoint
    g.lineTo(2, -2);  # rnotch
    g.lineTo(0, -5);  # tip
    g.lineTo(-2, -2); # lnotch
    g.lineTo(-4, -3); # lpoint
    g.lineTo(-2, -0); # ship


  fire: (event) ->
    # debounce
    if @state != event
      @state = event
      switch @state
        when 'jump'
          @anim.gotoAndPlay 'fly'
        when 'hit'
          @anim.gotoAndPlay 'splat'
        else
          @anim.gotoAndPlay 'run'


  tick: ->
    dt = INTERVAL / 1000

    switch @state
      when 'jump'
        accel = JetpackThrust
        @flame.visible = true
      when 'hit'
        accel = 0
        @v = 0
        @flame.visible = false
      else
        accel = Gravity
        @flame.visible = false

    @v += accel * dt

    @y += @v * dt

    if @y > FLOOR_LEVEL
      @y = FLOOR_LEVEL
      @bumpedFloor()
      @v = 0

    if @y < CEILING_LEVEL
      @y = CEILING_LEVEL
      @bumpedCeiling()
      @v = 0



  bumpedCeiling: ->

  bumpedFloor: ->



class Collider
  # constructor: ->

  collide: (player, colliders) ->
    for collider in colliders
      if collider.contains player #player.x, player.y
        player.fire 'hit'



class Stats
  constructor: (stage) ->

    @fps = new Text("Hello again", "bold 12px Arial", "#00FF55")
    @fps.x = 10
    @fps.y = 20
    @fps.text = ""
    stage.addChild(@fps)

    @score = new Text("", "bold 32px Arial", "#FF0055")
    @score.x = WIDTH - 200
    @score.y = 40
    @score.text = "Score"
    stage.addChild @score

  tick: ->
    @fps.text = Ticker.getMeasuredFPS().toString().substring(0,2)



#######################
#  sectors & friends  #
#######################

class Sky extends Bitmap
  constructor: () ->
    Bitmap.prototype.initialize.apply(@)


class Grass extends Bitmap
  constructor: () ->
    Bitmap.prototype.initialize.apply(@)


class Obstacle extends Bitmap
  constructor: (image, @x, @y, @width, @height) ->
    Bitmap.prototype.initialize.apply(@, [image])

  contains: (t) ->
    {x: x, y: y} = t.localToLocal(0,0,@)

    if x + t.width > 0 && y + t.height > 0
      true
    else
      false


class Word extends Text
  constructor: (word, @x, @y, @width, @height) ->
    Text.prototype.initialize.apply(@, ["", "36px Arial", "#F00"])
    @text = word

  contains: (t) ->
    console.log "contains", @localToLocal(0,0, t)


InitialLevelSpeed = 2.5

class Sector extends Container
  constructor: (@game) ->
    Container.prototype.initialize.apply(@)
    @speed = InitialLevelSpeed
    @colliders = []
    @next_building_time = 0
    @next_building_jitter = 200

    @obstacle()

  tick: ->
    @remove_children()
    if not @game.dead
      @generate()
      @x -= @speed

      @colliders = []
      @colliders.push @getChildAt(0) if @getNumChildren() > 0
      @colliders.push @getChildAt(1) if @getNumChildren() > 1

  generate: ->
    @obstacle() if @next_building_time <= 0
    @next_building_time -= 1

  obstacle: ->
    image = Math.floor(Math.random() * 5)

    [width,height] = building_dimensions[image]

    x = -@x + WIDTH
    y = HEIGHT - height

    bitmap = new Obstacle("images/buildings/00#{image}.jpg", x, y, width, height)
    @addChild bitmap
    @next_building_time = bitmap.width + Math.random() * @next_building_jitter
    @next_building_jitter -= 2.0
    @next_building_jitter = 30 if @next_building_jitter < 30
    @word bitmap

  word: (obstacle) ->
    text = words[Math.floor(Math.random() * words.length)]
    x_pos = obstacle.x + (obstacle.width/2 - 25)
    word = new Word(text, x_pos, obstacle.y - 10, 150, 50)
    @addChild word

  remove_children: ->
    return if @getNumChildren() == 0
    child = @getChildAt 0
    abs_x = @x + child.x + child.width
    if abs_x < 0
      @removeChild child
      @removeChildAt 0




##################
#  All the game  #
##################

KEYCODE_SPACE = 32
KEYCODE_UP = 38
KEYCODE_LEFT = 37
KEYCODE_RIGHT = 39
KEYCODE_W = 87
KEYCODE_A = 65
KEYCODE_D = 68
KEYCODE_ESC = 27

class Logo
  constructor: (@stage, @game) ->
    @logo = new Bitmap("images/logo.jpg")
    @stage.addChild @logo
    $(document).keyup @handleKeyUp

  handleKeyUp: (e) =>
    e.stopPropagation()
    switch e.keyCode
      when KEYCODE_SPACE
        console.log 'START'
        $(document).unbind 'keyup', @handleKeyUp
        @stage.removeAllChildren()
        Ticker.addListener @game
        @game.start_game()

  tick: ->
    @stage.update()

class Game
  constructor: (@stage) ->
    @collider = new Collider

    @dead = false
    @player = new Player(@)

    @jumpHeld = false

    @started = false

  fire: (event) ->
    switch event
      when 'dead'
        @dead = true
      else
        @player.fire(event)


  handleKeyDown: (e) =>
    e.stopPropagation()
    switch e.keyCode
      when KEYCODE_SPACE
        if @dead
          @game_over = false
          @dead = false
          @stage.removeAllChildren()
          @start_game()
        else
          @fire('jump')
      when KEYCODE_ESC
        @paused = not @paused
        Ticker.setPaused @paused

  handleKeyUp: (e) =>
    e.stopPropagation()
    switch e.keyCode
      when KEYCODE_SPACE
        @fire('unjump')


  tick: ->

    if not @started
      $(document).keydown @handleKeyDown
      $(document).keyup @handleKeyUp
      @started = true
      return

    if @dead
      return if @game_over
      # show game over
      @go = new Bitmap("images/game_over.jpg")
      @go.x = 130
      @go.y = 160
      @stage.addChild @go
      @game_over = true

    else
      @check_sky()
      @check_grass()
      @collider.collide(@player, @sector.colliders)

      @stats.score.text = "Score: " + @player.score
      @stats.tick()

      @stage.update()


  dead: ->

  start_game: ->
    @sky1 = new Bitmap("images/sky.jpg")
    @sky2 = new Bitmap("images/sky.jpg")
    @stage.addChild @sky1
    @stage.addChild @sky2
    @sky2.x += SKY_WIDTH

    @sector = new Sector(@)
    @stage.addChild @sector
    @stage.addChild @player
    @stats = new Stats @stage

    @grass1 = new Bitmap("images/grass.png")
    @grass2 = new Bitmap("images/grass.png")
    @stage.addChild @grass1
    @stage.addChild @grass2
    @grass1.y = HEIGHT - 30
    @grass2.y = HEIGHT - 30
    @grass2.x += GRASS_WIDTH

  check_sky: ->
    @sky1.x -= SKY_SPEED
    @sky2.x -= SKY_SPEED
    @sky1.x += SKY_WIDTH * 2 if @sky1.x < -SKY_WIDTH
    @sky2.x += SKY_WIDTH * 2 if @sky2.x < -SKY_WIDTH

  check_grass: ->
    @grass1.x -= GRASS_SPEED
    @grass2.x -= GRASS_SPEED
    @grass1.x += GRASS_WIDTH * 2 if @grass1.x < -GRASS_WIDTH
    @grass2.x += GRASS_WIDTH * 2 if @grass2.x < -GRASS_WIDTH

$ ->

  Ticker.setInterval INTERVAL

  canvas = $('#testCanvas')
  canvas.attr('width', WIDTH)
  canvas.attr('height', HEIGHT)

  stage = new Stage(canvas[0])

  game = new Game(stage)

  logo = new Logo(stage, game)

  Ticker.addListener logo

