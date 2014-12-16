class @Motion
  constructor: (opts) ->
    @options = opts || {}
    @outputel = document.getElementById('output')
    @outputel.setAttribute('style', 'display:block;') if @outputel && @options.log == true

    @radius = 50

    @twoEl = document.getElementById('motion-anim');
    @two = new Two(fullscreen: true).appendTo(@twoEl)

    @circle = @two.makeCircle(0,0, @radius)    
    @circle.fill = '#FF8000'
    @circle.stroke = 'orangered'
    @circle.linewidth = 5;

    @c = @two.makeCircle(0, -@radius - 30, 20)
    @c.fill = '#0080FF'
    @c.stroke = 'blue'
    @c.linewidth = 3;

    @rotator = @two.makeGroup(@c)
    # @rotator.translation.set(@two.width/2, @two.height/2)

    @scaler = @two.makeGroup(@circle, @rotator)
    @scaler.translation.set(@two.width/2, @two.height/2)

    @orienter = new Orienter()

    console.log @two
    console.log @circle


  output: (msg) ->
    @msgs ||= []
    @msgs.unshift(msg)
    @msgs.pop() if @msgs.length > 10

    if @outputel && @options.log == true
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
        # @output 'Rot: ' + [event.alpha, event.beta, event.gamma].join(', ')
        @rotator.rotation = event.alpha / 180 * Math.PI
        @output 'Cumulative: '+@orienter.cumulative + ' ('+@orienter.rotationIndex+')'
        @scaler.scale = @orienter.cumulative / 180


