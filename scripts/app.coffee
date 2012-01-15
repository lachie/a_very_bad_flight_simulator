
FPS = 60
INTERVAL = 1 / FPS * 1000


WIDTH=600
HEIGHT=400

FLOOR_LEVEL = HEIGHT - 100
CEILING_LEVEL = 10

Gravity = 475
JetpackThrust = -800

SKY_WIDTH = 900

# the player
widths = [29,32,29,31,31]

building_dimensions = [
  [190,265]
  [194,259]
  [220,220]
  [253,204]
  [181,132]
]


spriteData =
  images: ["images/mario.png"]
  # images: ["images/mariosplat.png"],
  frames: {width: 30, height: 16, count: 10}
  #frames: {width: 32, height: 32, count: 4}
  animations:
    run:
      frames: [6,6,6,7,7,7,7,7,8,8,8]
      next: true

    fly:
      frames: [5] #6,6,7,7,7,8,8]
      next: true

    splat:
      frames: [1,1,1,1,1,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4]
      image: 0

#spriteData.frames = []
#offset = 0
#for width,i in widths
  #spriteData.frames.push [offset, 0, width, 16] #, i, 0, 0]
  #offset += width




class Player extends Container
  constructor: (@game) ->
    Container.prototype.initialize.apply(@)

    @spriteSheet = new SpriteSheet(spriteData)
    @anim = new BitmapAnimation(@spriteSheet)
    @anim.gotoAndPlay 'run'

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
    @state = event
    switch @state
      when 'jump'
        @anim.gotoAndPlay 'fly'
      else
        @anim.gotoAndPlay 'run'


  tick: ->
    dt = INTERVAL / 1000

    switch @state
      when 'jump'
        accel = JetpackThrust
        @flame.visible = true
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
        console.log "hit"



class Stats
  constructor: (stage) ->

    @fps = new Text("Hello again", "bold 12px Arial", "#00FF55")
    @fps.x = 10
    @fps.y = 20
    @fps.text = ""
    stage.addChild(@fps)

    @sectors = new Text("Hello again", "bold 12px Arial", "#FF0055")
    @sectors.x = 100
    @sectors.y = 20
    @sectors.text = "Sectors"
    stage.addChild @sectors

  tick: ->
    @fps.text = Ticker.getMeasuredFPS().toString().substring(0,2)



#######################
#  sectors & friends  #
#######################

class Sky extends Bitmap
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



InitialLevelSpeed = 2.5

class Sector extends Container
  constructor: (@level) ->
    Container.prototype.initialize.apply(@)
    @threshold = 0.004
    @speed = InitialLevelSpeed
    @colliders = []

    @obstacle()

  tick: ->
    @remove_children()
    @generate()
    @x -= @speed

    #x = @x
    #@obstaclesInPlay = _.filter @obstaclesInPlay, ( (obstacle) -> x + obstacle.x > 0 )
    #@colliders.push @obstaclesInPlay[0] if @obstaclesInPlay.length

    @colliders = []
    @colliders.push @getChildAt(0) if @getNumChildren() > 0

  generate: ->
    if Math.random() < @threshold
      @obstacle()

    #@obstaclesInPlay = _.sortBy @children, (child) -> child.x

  obstacle: ->
    image = Math.floor(Math.random() * 5)

    [width,height] = building_dimensions[image]

    x = -@x + WIDTH
    y = HEIGHT - height

    bitmap = new Obstacle("images/buildings/00#{image}.jpg", x, y, width, height)
    @addChild bitmap

  remove_children: ->
    return if @getNumChildren() == 0
    child = @getChildAt 0
    abs_x = @x + child.x + child.width
    @removeChild child if abs_x < 0




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

class Game
  constructor: (@stage) ->
    @collider = new Collider

    @level = 0
    @player = new Player(@)


    @jumpHeld = false

    $(document).keydown @handleKeyDown
    $(document).keyup @handleKeyUp

    @sky1 = new Bitmap("images/sky.jpg")
    @sky2 = new Bitmap("images/sky.jpg")
    stage.addChild @sky1
    stage.addChild @sky2
    @sky2.x += SKY_WIDTH

    @sector = new Sector @level
    @stage.addChild @sector
    @stage.addChild @player
    @stats = new Stats @stage


  fire: (event) ->
    @player.fire(event)


  handleKeyDown: (e) =>
    e.stopPropagation()
    switch e.keyCode
      when KEYCODE_SPACE
        unless @jumpHeld
          @fire('jump')
          @jumpHeld = true
      when KEYCODE_ESC
        @paused = not @paused
        Ticker.setPaused @paused



  handleKeyUp: (e) =>
    e.stopPropagation()
    switch e.keyCode
      when KEYCODE_SPACE
        if @jumpHeld
          @fire('unjump')
          @jumpHeld = false


  tick: ->
    @check_sky()
    @collider.collide(@player, @sector.colliders)

    @stage.update()

    @stats.sectors.text = "Sector " + @sector.level.toString()
    @stats.tick()

    # @sector.tick()


  check_sky: ->
    @sky1.x -= 0.15
    @sky2.x -= 0.15
    @sky1.x += SKY_WIDTH * 2 if @sky1.x < -SKY_WIDTH
    @sky2.x += SKY_WIDTH * 2 if @sky2.x < -SKY_WIDTH

$ ->
  canvas = $('#testCanvas')
  canvas.attr('width', WIDTH)
  canvas.attr('height', HEIGHT)

  stage = new Stage(canvas[0])


  game = new Game(stage)


  Ticker.setInterval INTERVAL
  Ticker.addListener game
