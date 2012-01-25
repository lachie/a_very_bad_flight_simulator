
FPS = 60
INTERVAL = 1 / FPS * 1000


WIDTH=600
HEIGHT=400

FLOOR_LEVEL = HEIGHT - 3 - 32
CEILING_LEVEL = 10

Gravity = 275
JetpackThrust = -800

SKY_WIDTH = 2135
SKY_SPEED = 1.4
GRASS_WIDTH = 600
GRASS_SPEED = 4.0

BUILDING_DENSITY_FACTOR = 0.005

PLAYER_X_OFFSET = 100

# the player
widths = [29,32,29,31,31]

building_dimensions = [
  [190,265]
  [194,259]
  [220,220]
  [253,204]
  [181,132]
  [267,200]
]

words = "FISH CAT HAT POO BUM RED BLUE
        ENNUI DEPRESSION MORTGAGE
        RUMPYPUMPY WHISKEY
        ROBUST BUXOM WANTON INTERCOURSE"

words = words.split(/\s+/)

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
      frames: [12,12,13,13,13,14,14,14,15,15,15,15,16,16,16,16,17,17,17,17]
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
for i in [0...8]
  spriteData.frames.push [0, offset, width, height, 1]
  offset += height
  count += 1



frames = for i in [0...8]
  num = i + 12
  [ num, num, num, num ]
spriteData.animations.splat.frames = _.flatten frames



sparklesFrameData =
  images: ["images/sparkle_21x23.png"]
  frames: {width:21,height:23,regX:10,regY:11}


randInt = (lo, hi) =>
  Math.floor(Math.random() * (hi - lo)) + lo

filetype = () =>
  agent = navigator.userAgent.toLowerCase()
  if(agent.indexOf("chrome") > -1)
    return ".mp3"
  else if(agent.indexOf("opera") > -1)
    return ".ogg"
  else if(agent.indexOf("firefox") > -1)
    return ".ogg"
  else if(agent.indexOf("safari") > -1)
    return ".mp3"
  else if(agent.indexOf("msie") > -1)
    return ".mp3"


soundFiletype = filetype()

class Player extends Container
  constructor: (@game) ->
    Container.prototype.initialize.apply(@)

    @sparkles = []

    @makeAnim()
    @makeSparkles()
    @drawFlame()

    @v = 0

    @y = 0
    @x = PLAYER_X_OFFSET

    @scaleX = 2
    @scaleY = 2

    @width = 30
    @height = 16


    @addChild @flame
    @addChild @anim

    @score = 0

    @ticks = 0



  finishedDying: ->
    @game.fire('dead')



  addScore: (score) ->
    @score += score
    @addSparkle()
    SoundJS.play "score", SoundJS.INTERRUPT_NONE, 0.2


  makeAnim: ->

    @spriteSheet = new SpriteSheet(spriteData)
    @anim = new BitmapAnimation(@spriteSheet)
    @anim.player = @
    @anim.gotoAndPlay 'run'

    player = @

    @anim.onAnimationEnd = (anim, anim) ->
      if anim == 'splat'
        player.finishedDying()


  drawFlame: ->
    @flame = new Shape()

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

    g.moveTo(2, 0)   # ship
    g.lineTo(4, -3)  # rpoint
    g.lineTo(2, -2)  # rnotch
    g.lineTo(0, -5)  # tip
    g.lineTo(-2, -2) # lnotch
    g.lineTo(-4, -3) # lpoint
    g.lineTo(-2, -0) # ship


  makeSparkles: ->
    @bmpAnim = new BitmapAnimation(new SpriteSheet(sparklesFrameData))


  addSparkle: ->
    sparkle = @bmpAnim.clone()

    #sparkle.x = Math.random() * 100
    #sparkle.y = Math.random() * 100

    sparkle.gotoAndPlay Math.random() * sparkle.spriteSheet.getNumFrames() | 0

    speed = .5

    angle = Math.PI * 2 * Math.random()
    v = (Math.random() - 0.5) * 30 * speed

    sparkle.vX = Math.cos(angle) * v
    sparkle.vY = Math.sin(angle) * v

    sparkle.vS = (Math.random()-0.5)*0.2
    sparkle.vA = -Math.random()*0.05-0.01

    @sparkles.push sparkle
    @addChild sparkle


  fire: (event, args...) ->

    return if @state == 'die' || @state == 'dying'

    # debounce
    if @state != event
      @state = event
      switch @state
        when 'jump'
          @anim.gotoAndPlay 'fly'
        when 'die'
          @die()
          @anim.gotoAndPlay 'splat'
        when 'unjump'
          @anim.gotoAndPlay 'run'

  die: ->
    @state = 'dying'
    @game.fire 'dying'
    @anim.gotoAndPlay 'splat'
    SoundJS.play "explosion"


  finishedDying: ->
    @game.fire('dead')


  tick: ->
    dt = INTERVAL / 1000

    switch @state
      when 'jump'
        accel = JetpackThrust
        @flame.visible = true
        SoundJS.play "rocket", SoundJS.INTERRUPT_NONE, 0.2
      when 'die', 'dying'
        accel = Gravity / 2
        #@v = 0
        @flame.visible = false

        if @y <= 0
          @finishedDying()
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


    newSparkles = []
    for sparkle in @sparkles
      #sparkle.vY += 2
      # sparkle.vX *= 0.98

      sparkle.x += sparkle.vX
      sparkle.y += sparkle.vY

      #sparkle.scaleX = sparkle.scaleY = sparkle.scaleX + sparkle.vS
      sparkle.alpha += sparkle.vA

      if sparkle.alpha <= 0
        @removeChild sparkle
      else
        newSparkles.push sparkle

    @sparkles = newSparkles

    #eif @sparkles.length > 10



  bumpedCeiling: ->

  bumpedFloor: ->



class Collider
  # constructor: ->

  collide: (player, colliders) ->
    for collider in colliders
      if collider.contains player #player.x, player.y
        collider.hit player
        break



class Stats
  constructor: (stage) ->

    @fps = new Text("Hello again", "bold 12px Arial", "#00FF55")
    @fps.x = 10
    @fps.y = 20
    @fps.text = ""
    stage.addChild(@fps)

    @score = new Text("", "bold 32px Arial", "#FF0055")
    @score.x = WIDTH - 250
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
    Bitmap.prototype.initialize.apply @


class Grass extends Bitmap
  constructor: () ->
    Bitmap.prototype.initialize.apply @


class Building extends Shape
  constructor: (@x)->
    Shape.prototype.initialize.apply @
    @structure()
    @scaffolding()
    @windows()

  structure: ->
    @floor_height = randInt(16, 22)
    @column_width = randInt(14, 22)
    @columns = randInt(4, 8)
    @floors = randInt(4, 15)
    console.log "structure #{@floors} #{@columns}"
    @gap = 6
    @height = (@floor_height + @gap) * @floors
    @width = (@column_width + @gap) * @columns
    @y = HEIGHT - @height

  windows: ->
    @graphics.setStrokeStyle(1)
    @graphics.beginStroke(Graphics.getRGB(50,50,50))
    for c in [0...@columns]
      for f in [0...@floors]
        x = @gap / 2 + (c * (@column_width + @gap))
        y = (HEIGHT - (@gap / 2) - @floor_height) - (f * (@floor_height + @gap))
        console.log "floor y #{y}"
        @graphics.beginFill @window_colour()
        @graphics.drawRoundRect x, y, @column_width, @floor_height, 2
        @graphics.endFill()
    @graphics.endStroke()

  window_colour: ->
    Graphics.getHSL(randInt(170, 220), randInt(60, 70), randInt(70, 80))

  scaffolding: ->
    @graphics.setStrokeStyle(2)
    @graphics.beginStroke(Graphics.getRGB(20,20,20))
    @graphics.beginFill(Graphics.getHSL(randInt(0, 360), 20, randInt(20, 50)))
    @graphics.drawRect(0,HEIGHT - @height ,@width, @height)
    @graphics.endFill()
    @graphics.endStroke()

  contains: (t) ->
    {x: x, y: y} = t.localToLocal(0,0,@)
    x + t.width > 0 && y + t.height > 0

  is_collidable: (p) ->
    {x: x, y: y} = p.localToLocal(0,0,@)
    x < @width

  hit: (player) ->
    player.die()


class Obstacle extends Bitmap
  constructor: (image, @x, @y, @width, @height) ->
    Bitmap.prototype.initialize.apply(@, [image])

  contains: (t) ->
    {x: x, y: y} = t.localToLocal(0,0,@)
    x + t.width > 0 && y + t.height > 0

  is_collidable: (p) ->
    {x: x, y: y} = p.localToLocal(0,0,@)
    x < @width

  hit: (player) ->
    player.die()

class Word extends Text
  constructor: (word, @x, @y) ->
    Text.prototype.initialize.apply(@, ["", "36px Arial", "#F00"])

    @textBaseline = 'top'
    @text = word
    @width = @getMeasuredWidth()
    @height = @getMeasuredLineHeight()
    @y -= @height

  tick: ->
    if @wasHit
      @color = '#400'

  contains: (t) ->
    {x: x, y: y} = t.localToLocal(0,0,@)
    x + t.width > 0 && y + t.height > -@height && y < @height

  hit: (player) ->
    player.addScore(100)
    @wasHit = true


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
    return if @stopped

    @remove_children()
    if not @game.dead
      @generate()
      @x -= @speed

      @colliders = []
      child_count = @getNumChildren()
      for i in [0...child_count] by 2
        child = @getChildAt i
        if child.is_collidable(@game.player)
          @colliders.push @getChildAt(i)
          @colliders.push @getChildAt(i+1)
          return

  generate: ->
    @obstacle() if @next_building_time <= 0
    @next_building_time -= 1

  obstacle: ->
    image = Math.floor(Math.random() * building_dimensions.length)

    [width,height] = building_dimensions[image]

    x = -@x + WIDTH
    y = HEIGHT - height

    obstacle = new Obstacle("images/buildings/00" + image + ".jpg", x, y, width, height)
    this.addChild(obstacle)
    this.next_building_time = obstacle.width + Math.random() * this.next_building_jitter

    #building = new Building x, y
    @addChild obstacle
    @next_building_time = obstacle.width + Math.random() * @next_building_jitter
    @next_building_jitter -= 2.0
    @next_building_jitter = 30 if @next_building_jitter < 30
    @word obstacle


  word: (obstacle) ->
    text = words[Math.floor(Math.random() * words.length)]
    x_pos = obstacle.x + (obstacle.width/2 - 25)
    console.log "obstacle.y #{obstacle.y}"
    console.log "obstacle.height #{obstacle.height}"
    word = new Word(text, x_pos, obstacle.y)
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



class GameState
  constructor: (@stage) ->

  enter: ->
    $(document).keyup @handleKeyUp
    $(document).keydown @handleKeyDown

  exit: ->
    $(document).unbind 'keyup', @handleKeyUp
    $(document).unbind 'keydown', @handleKeyDown
    @stage.removeAllChildren()

  tick: ->
    @stage.update()


  changeState: (state) ->
    @exit()
    Ticker.removeListener(@)
    state.enter()
    Ticker.addListener(state)

  handleKeyDown: =>
    console.log "base kd"
  handleKeyUp: =>
    console.log "base ku"


class Logo extends GameState
  constructor: (@stage, @game) ->
    super


  enter: ->
    super
    @logo = new Bitmap("images/logo.jpg")
    @stage.addChild @logo

    @stage.clearEvents()
    @stage.onClick = =>
      console.log "onclick in logo"
      @changeState @game



  handleKeyUp: (e) =>
    e.stopPropagation()
    switch e.keyCode
      when KEYCODE_SPACE
        @changeState @game





class Game extends GameState
  constructor: (@stage) ->
    @collider = new Collider

    @state = 'init'


  enter: ->
    super
    @stage.clearEvents()
    @start_game()

    @stage.onMouseDown = =>
      switch @state
        when 'running'
          @player.fire('jump')
        when 'dead'
          @changeState @

    @stage.onMouseUp = =>
      @player.fire('unjump')

  fire: (event, args...) ->
    switch event
      when 'dead'
        @state = 'dead'

      when 'dying'
        @state = 'dying'


  handleKeyDown: (e) =>
    e.stopPropagation()
    e.preventDefault()
    switch e.keyCode
      when KEYCODE_SPACE
        switch @state
          when 'running'
            @player.fire('jump')
          when 'dead'
            @changeState @
      when KEYCODE_ESC
        @paused = not @paused
        Ticker.setPaused @paused


  handleKeyUp: (e) =>
    e.stopPropagation()
    e.preventDefault()
    switch e.keyCode
      when KEYCODE_SPACE
        @player.fire('unjump')


  tick: ->
    switch @state
      when 'dying'
        0

      when 'dead'
        unless @game_over
          # show game over
          @go = new Bitmap("images/game_over.jpg")
          @go.x = 130
          @go.y = 160
          @stage.addChild @go

          @sector.stopped = true

          @game_over = true

      else # normal game
        @check_sky()
        @check_grass()
        @collider.collide(@player, @sector.colliders)

        @stats.score.text = "Score: " + @player.score
        @stats.tick()

    @stage.update()

  start_game: ->
    @state = 'starting'
    @game_over = false

    @player = new Player(@)
    @player.score = 0

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
    @grass1.y = HEIGHT - 40
    @grass2.y = HEIGHT - 40
    @grass2.x += GRASS_WIDTH

    @state = 'running'


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

  SoundJS.addBatch([
    {name:"explosion", src:"/sounds/exp2" + soundFiletype, instances:1},
    {name:"rocket", src:"/sounds/rocket" + soundFiletype, instances:1},
    {name:"score", src:"/sounds/score" + soundFiletype, instances:1}
    ])

  Ticker.setInterval INTERVAL

  canvas = $('#testCanvas')
  canvas.attr('width', WIDTH)
  canvas.attr('height', HEIGHT)

  stage = new Stage(canvas[0])
  stage.mouseEnabled = true
  Touch.enable(stage)

  stage.clearEvents = ->
    @onClick = null
    @onMouseUp = null
    @onMouseDown = null

  game = new Game(stage)

  logo = new Logo(stage, game)
  logo.enter()
  Ticker.addListener logo

