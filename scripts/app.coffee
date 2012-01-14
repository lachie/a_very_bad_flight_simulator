console.log "app cawfee"

FPS = 60
INTERVAL = 1 / FPS * 1000

console.log INTERVAL

WIDTH=600
HEIGHT=400

FLOOR_LEVEL = HEIGHT - 100
CEILING_LEVEL = 10

Gravity = 275
JetpackThrust = -800

SKY_WIDTH = 900

widths = [29,32,29,31,31]
building_heights = [265,259,220,204,132]

spriteData =
  images: ["images/mario.png"],
  frames: {width: 30, height: 16, count: 10}
  animations:
    run:
      frames: [6,6,6,7,7,7,7,7,8,8,8]
      next: true

    fly:
      frames: [5] #6,6,7,7,7,8,8]
      next: true

#spriteData.frames = []
#offset = 0
#for width,i in widths
  #spriteData.frames.push [offset, 0, width, 16] #, i, 0, 0]
  #offset += width

console.log "sd", spriteData.frames

#Player = new Container()
#Player.prototype.Container_initialize = Player.prototype.initialize

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

  collide: (player, obstacles) ->
    for obstacle in obstacles
      console.log player.y, obstacle.y
      if player.y > obstacle.y
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

class Sky extends Bitmap

  constructor: () ->
    Bitmap.prototype.initialize.apply(@)


class Obstacle extends Bitmap
  constructor: (@x, @y, @width, @height) ->
    Bitmap.prototype.initialize.apply(@)

class Sector extends Container
  constructor: (@level) ->
    Container.prototype.initialize.apply(@)

    @max_objects = 3 + @level
    @length = 1000 + @level * 200
    @generate()

  tick: ->
    @x -= @speed()

  generate: ->
    for i in [0...@max_objects]
      @obstacle i

  obstacle: (n) ->
    image = Math.floor(Math.random() * 5)
    width = Math.random() * 50 + 20

    x = WIDTH  + (n * (@length / @max_objects))
    y = HEIGHT - building_heights[image]

    bitmap = new Bitmap("images/buildings/00#{image}.jpg")
    bitmap.x = x
    bitmap.y = y
    @addChild bitmap

    @obstacles = @children


  speed: ->
    1.0 + @level * 0.5


KEYCODE_SPACE = 32
KEYCODE_UP = 38
KEYCODE_LEFT = 37
KEYCODE_RIGHT = 39
KEYCODE_W = 87
KEYCODE_A = 65
KEYCODE_D = 68

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


  handleKeyUp: (e) =>
    e.stopPropagation()
    switch e.keyCode
      when KEYCODE_SPACE
        if @jumpHeld
          @fire('unjump')
          @jumpHeld = false


  tick: ->
    @check_sky()
    @collider.collide(@player, @sector.obstacles)

    @stage.update()

    @stats.sectors.text = "Sector " + @sector.level.toString()
    @stats.tick()

    # @sector.tick()

    if @sector.x < -(@sector.length + WIDTH)
      @stage.removeChild @sector
      @level += 1
      @sector = new Sector @level
      @stage.addChild @sector

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
