class @Accelerometer
  constructor: (opts) ->
    @options = opts
    @el = document.getElementById('output')

  output: (msg) ->
    @el.innerHTML = msg

  start: ->
    @output "Starting accelerometer"
    if !navigator
      @output "No navigator"
      return

    if !navigator.accelerometer
      @output "No accelerometer"
      return

    @watchID = navigator.accelerometer.watchAcceleration(@onSuccess, @onError, frequency: 1)

  stop: ->
    return if !@watchID
    navigator.accelerometer.clearWatch(@watchID)
    @output "Stopped accelerometer"
    @watchID = null

  onSuccess: (acc) ->
    @output "Acceleration: " + acc.x + "," + acc.y + "," + acc.z;

  onError: (err) ->
    @output 'Error: ' + err



