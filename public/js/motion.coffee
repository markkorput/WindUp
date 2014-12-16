class @Motion
  constructor: (opts) ->
    @options = opts
    @outputel = document.getElementById('output')

    @twoEl = document.getElementById('motion-anim');
    console.log @twoEl
    @two = new Two(fullscreen: true).appendTo(@twoEl)
    console.log @two
    @circle = @two.makeCircle(@two.width*0.5, @two.height*0.5, 50)
    console.log @circle
    @circle.fill = '#FF8000'
    @circle.stroke = 'orangered'
    @circle.linewidth = 5;
    @two.update();


  output: (msg) ->
    @msgs ||= []
    @msgs.unshift(msg)
    @msgs.pop() if @msgs.length > 10

    if @outputel
      @outputel.innerHTML = @msgs.join('\n')
    # else
    #  console.log msg

  start: ->
    @output "Starting motion sensor..."

    if !window.DeviceMotionEvent
      @output "Motion events not supported on this device..."
      return

    window.ondevicemotion = @onMotion
    # setInterval @update, 100
    @two.bind 'update', @update
    @two.play()

  onMotion: (event) =>
    # console.log 'got motion:', event

    if !@lastEvent
      console.log event

    @lastEvent = event

  update: (frameCount) =>
    if !@lastEvent
      @output 'No motion data'
      return

    # console.log @lastEvent
    @output 'Motion: ' + @lastEvent.accelerationIncludingGravity.x + ',' + @lastEvent.accelerationIncludingGravity.y
