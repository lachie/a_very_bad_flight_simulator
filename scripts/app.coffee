console.log "app cawfee"

widths = [29,32,29,31,31]

spriteData =
  images: ["images/mario.png"],
  frames: {width: 30, height: 16, count: 10}
  animations:
    run:
      frames: [6,7,8]
      next: true

#spriteData.frames = []
#offset = 0
#for width,i in widths
  #spriteData.frames.push [offset, 0, width, 16] #, i, 0, 0]
  #offset += width


console.log "sd", spriteData.frames


class Player
  constructor: ->
    @spriteSheet = new SpriteSheet(spriteData)
    @anim = new BitmapAnimation(@spriteSheet)
    @anim.gotoAndPlay 'run'

  addChildren: (stage) ->
    stage.addChild @anim



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

    stage.addChild(@sectors)

  update: ->
    @fps.text = Ticker.getMeasuredFPS().toString().substring(0,4)

class Obstacle
  constructor: (stage, @speed) ->
    # create a shape to draw the background into:
    @bg = new Shape()
    @height ||= Math.random() * 150 + 20
    @width ||= Math.random() * 50 + 20

    # note how the drawing instructions can be chained together.
    @bg.graphics.beginStroke("#444").beginFill(Graphics.getHSL(Math.random()*360, 100, 50))
      .drawRect(600, 350 - @height, @width, @height)
    stage.addChild(@bg)

  update: ->
    @bg.x -= @speed


class Sector
  constructor: (@stage) ->
    @objects = []
    @max_objects = 10
    @sector_count = 0
    @base_prob = 0.003

  reset: ->
    @objects = []
    @stage.clear()
    @sector_count += 1

  update: ->
    @reset() if @objects.length >= @max_objects
    if @wait > 0
      @wait -= 1
    else
      @generate()
    for object,i in @objects
      object.update()

  generate: ->
    if Math.random() < @prob() && @objects.length < @max_objects
      console.log "Sector generated object"
      obstacle = new Obstacle @stage, @speed()
      @objects.push obstacle
      @wait = obstacle.width + 50
      return
    @wait = 0

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

    @player = new Player

    @player.addChildren @stage

    @sector = new Sector @stage

    @stats = new Stats @stage

    document.onkeydown = @handleKeyDown
    document.onkeyup = @handleKeyUp

  handleKeyDown: (e) =>
    e ||= window.event
    switch e.keyCode
      when KEYCODE_SPACE
        @jumpHeld = true

  handleKeyUp: (e) =>
    e ||= window.event
    switch e.keyCode
      when KEYCODE_SPACE
        @jumpHeld = false


  tick: ->
    @stage.update()
    @stats.sectors.text = "Sector " + @sector.sector_count.toString()
    @stats.update()
    @sector.update()


$ ->
  console.log "app cawfee"
  canvas = document.getElementById("testCanvas")
  console.log "c", canvas
  stage = new Stage(canvas)


  game = new Game(stage)

  Ticker.setFPS 60
  Ticker.addListener game
