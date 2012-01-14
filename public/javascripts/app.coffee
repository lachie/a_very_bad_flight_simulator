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

  var KEYCODE_SPACE = 32;		//usefull keycode
  var KEYCODE_UP = 38;		//usefull keycode
  var KEYCODE_LEFT = 37;		//usefull keycode
  var KEYCODE_RIGHT = 39;		//usefull keycode
  var KEYCODE_W = 87;			//usefull keycode
  var KEYCODE_A = 65;			//usefull keycode
  var KEYCODE_D = 68;			//usefull keycode


  handleKeyUp: =>
  handleKeyDown: (e) =>
    e ||= window.event
    switch e.keyCode
      when KEYCODE_SPACE
        shootHeld = true
      when KEYCODE_A:
      when KEYCODE_LEFT:	lfHeld = true; break;
      when KEYCODE_D:
      when KEYCODE_RIGHT: rtHeld = true; break;
      when KEYCODE_W:
      when KEYCODE_UP:	fwdHeld = true; break;

    function handleKeyDown(e) {
	//cross browser issues exist
	}
}

function handleKeyUp(e) {
	//cross browser issues exist
	if(!e){ var e = window.event; }
	switch(e.keyCode) {
		case KEYCODE_SPACE:	shootHeld = false; break;
		case KEYCODE_A:
		case KEYCODE_LEFT:	lfHeld = false; break;
		case KEYCODE_D:
		case KEYCODE_RIGHT: rtHeld = false; break;
		case KEYCODE_W:
		case KEYCODE_UP:	fwdHeld = false; break;
	}
}

  tick: ->
    @stage.update()


$ ->
  console.log "app cawfee"
  canvas = document.getElementById("testCanvas")
  console.log "c", canvas
  stage = new Stage(canvas)


  game = new Game(stage)




  Ticker.setFPS 10
  Ticker.addListener game
