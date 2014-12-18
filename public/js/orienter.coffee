class @Orienter
  constructor: (opts) ->
    @options = opts
    @events = []
    @rotationIndex = 0
    @cumulative = 0

  start: ->
    if !window.DeviceOrientationEvent
      @output "Orientation events not supported"
    else
      window.addEventListener('deviceorientation', @onOrientation)

  onOrientation: (event) =>
    if !@last()
      console.log event # log the first event for debugging
      @startRotationValue = event.alpha

    # save last X events; shift latest event into the front of our array
    @events.unshift event

    # don't let the array get too long; remove (pop) the oldest events from the tail of our array
    @events.pop() while @events.length > 3

    if prev = @previous()
      # compair current rotation against last recorded rotation;
      # if difference is too big (> 300) assume we've passed the zero-degree-angle
      delta = event.alpha - prev.alpha
      if delta > 300 # assume we've rotated counter-clockwise past the 0-degree-angle
        @rotationIndex -= 1
      else if delta < -300 # assume we've rotated clockwise past the 0-degree-angle
        @rotationIndex += 1

    @cumulative = @rotationIndex * 360 + event.alpha - @startRotationValue

  previous: ->
    @events[1]

  last: ->
    @events[0]

