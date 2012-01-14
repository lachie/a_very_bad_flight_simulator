console.log "app cawfee"

FPS = 60
INTERVAL = 1 / FPS * 1000

console.log INTERVAL

WIDTH=600
HEIGHT=400

FLOOR_LEVEL = HEIGHT - 100
CEILING_LEVEL = 10

Gravity = 175
JetpackThrust = -350


widths = [29,32,29,31,31]

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


class Sector extends Container
  constructor: (@stage) ->
    Container.prototype.initialize.apply(@)
    @max_objects = 3
    @sector_count = 0
    @base_prob = 0.003
    @stage.addChild @

  reset: ->
    console.log "resetting"
    @removeAllChildren()
    @sector_count += 1

  tick: ->
    @reset() if @getNumChildren() >= @max_objects
    if @wait > 0
      @wait -= 1
    else
      @generate()
    for i in [0...@getNumChildren()]
      console.log "child #{i}"
      child = @getChildAt(i)
      @getChildAt(i).x -= @speed
      @getChildAt(i).draw(@stage.canvas.getContext('2d'))

  generate: ->
    if Math.random() < @prob() && @getNumChildren() < @max_objects
      @wait = @obstacle()
      return
    @wait = 0

  obstacle: ->
    bg = new Shape()
    height = Math.random() * 150 + 20
    width = Math.random() * 50 + 20

    # note how the drawing instructions can be chained together.
    bg.graphics.beginStroke("#000").beginFill(Graphics.getHSL(Math.random()*360, 100, 50))
      .drawRect(600, 350 - height, width, height)
    @.addChild(bg)

  prob: ->
    @base_prob + @sector_count * 0.01

  speed: ->
    0.5 + @sector_count * 0.5


KEYCODE_SPACE = 32
KEYCODE_UP = 38
KEYCODE_LEFT = 37
KEYCODE_RIGHT = 39
KEYCODE_W = 87
KEYCODE_A = 65
KEYCODE_D = 68


class Game
  constructor: (@stage) ->


    @player = new Player(@)

    @stage.addChild @player

    @jumpHeld = false

    $(document).keydown @handleKeyDown
    $(document).keyup @handleKeyUp


    @sector = new Sector @stage

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
    @stage.update()

    @stats.sectors.text = "Sector " + @sector.sector_count.toString()
    @stats.tick()
    @sector.tick()


$ ->
  canvas = $('#testCanvas')
  canvas.attr('width', WIDTH)
  canvas.attr('height', HEIGHT)

  stage = new Stage(canvas[0])


  game = new Game(stage)


  Ticker.setInterval INTERVAL
  Ticker.addListener game
