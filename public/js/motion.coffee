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


    @c = @two.makeCircle(0, -80, 20)
    @c.fill = '#0080FF'
    @c.stroke = 'blue'
    @c.linewidth = 3;

    @group = @two.makeGroup(@c)
    @group.translation.set(@two.width/2, @two.height/2)

    @orienter = new Orienter()

  output: (msg) ->
    @msgs ||= []
    @msgs.unshift(msg)
    @msgs.pop() if @msgs.length > 10

    if @outputel
      @outputel.innerHTML = @msgs.join('\n')
    # else
    #  console.log msg

  start: ->
    @orienter.start()

    @output "Starting motion sensor..."

    # if !window.DeviceMotionEvent
    #   @output "Motion events not supported on this device..."
    # else
    #   window.ondevicemotion = @onMotion

    # setInterval @update, 100
    @two.bind 'update', @update
    @two.play()

  onMotion: (event) =>
    # console.log 'got motion:', event

    if !@lastEvent
      console.log event

    @lastEvent = event

  update: (frameCount) =>
    #if @lastEvent
    #  @output 'Motion: ' + @lastEvent.accelerationIncludingGravity.x + ',' + @lastEvent.accelerationIncludingGravity.y

    event = @orienter.last()
    if event 
      @output 'Rot: ' + [event.alpha, event.beta, event.gamma].join(', ')

    @group.rotation = event.alpha / 180 * Math.PI
