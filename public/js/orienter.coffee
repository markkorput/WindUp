class @Orienter
  constructor: (opts) ->
    @options = opts
    @events = []

  start: ->
    if !window.DeviceOrientationEvent
      @output "Orientation events not supported"
    else
      window.addEventListener('deviceorientation', @onOrientation)

  onOrientation: (event) =>
    if !@last()
      console.log event # log the first event for debugging

    # save last X events; push latest event into the end of our array
    @events.push event

    # don't let the array get too long; remove the oldest event
    @events.shift() while @events.length > 3

  last: ->
    @events[@events.length - 1]

