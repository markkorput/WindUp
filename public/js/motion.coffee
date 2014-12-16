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
    @circle = @two.makeCircle(@two.width*0.5, @two.height*0.5, 50)
    @circle.fill = '#FF8000'
    @circle.stroke = 'orangered'
    @circle.linewidth = 5;

    @two.update();

    @c = @two.makeCircle(@two.width*0.5, @two.height*0.5+30, 20)
    @c.fill = '#0080FF'
    @c.stroke = 'blue'
    @c.linewidth = 5;


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
    else
      window.ondevicemotion = @onMotion

    if !window.DeviceOrientationEvent
      @output "Orientation events not supported"
    else
      window.addEventListener('deviceorientation', @onOrientation)

    # setInterval @update, 100
    @two.bind 'update', @update
    @two.play()

  onMotion: (event) =>
    # console.log 'got motion:', event

    if !@lastEvent
      console.log event

    @lastEvent = event

  onOrientation: (event) =>
    if !@lastOrientation
      console.log event

    @lastOrientation = event

  update: (frameCount) =>
    #if @lastEvent
    #  @output 'Motion: ' + @lastEvent.accelerationIncludingGravity.x + ',' + @lastEvent.accelerationIncludingGravity.y

    if @lastOrientation
      @output 'Rot: ' + [@lastOrientation.alpha, @lastOrientation.beta, @lastOrientation.gamma].join(', ')
