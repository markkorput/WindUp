class @Motion
  constructor: (opts) ->
    @options = opts
    @el = document.getElementById('output')

  output: (msg) ->
    @el.innerHTML = msg

  start: ->
    @output "Starting motion sensor..."

    if !window.DeviceMotionEvent
      @output "Motion events not supported on this device..."
      return

    window.ondevicemotion = @onMotion
    setInterval @update, 100

  onMotion: (event) =>
    # console.log 'got motion:', event
    @lastEvent = event

  update: =>
    if !@lastEvent
      @output 'No motion data'
      return

    # console.log @lastEvent
    @output 'Motion: ' + @lastEvent.accelerationIncludingGravity.x + ',' + @lastEvent.accelerationIncludingGravity.y
