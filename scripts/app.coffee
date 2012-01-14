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
    @v = 0


  addChildren: (stage) ->
    stage.addChild @anim


  tick: (dt) ->
    accel = 90

    dt /= 1000.0
    console.log "dt", dt

    #a = F/m
    #a = dx/dt

    @v += accel * dt
    # @anim.y = @anim.y * dt + 0.5 * accel * (dt^2)

    console.log @v, dt, "y", @anim.y

    @anim.y += Math.round(@v * dt)
    # @anim.x += 1


KEYCODE_SPACE = 32
KEYCODE_UP = 38
KEYCODE_LEFT = 37
KEYCODE_RIGHT = 39
KEYCODE_W = 87
KEYCODE_A = 65
KEYCODE_D = 68


class Game
  constructor: (@stage) ->

    scoreField = new Text("Hello again", "bold 12px Arial", "#FF0000")
    scoreField.x = 300
    scoreField.y = 300

    scoreField.text = "Hello cruel World"

    @stage.addChild(scoreField)


    @player = new Player

    @player.addChildren @stage


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


  tick: (dt) ->
    console.log "jumping", @jumpHeld
    @player.tick(dt)
    @stage.update()


$ ->
  console.log "app cawfee"
  canvas = document.getElementById("testCanvas")
  console.log "c", canvas
  stage = new Stage(canvas)


  game = new Game(stage)




  Ticker.setFPS 10
  Ticker.addListener game
