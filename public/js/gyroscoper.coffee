class @Gyroscoper
  constructor: (_opts) ->
    @options = _opts

  start: ->
    el = document.getElementById('output')
    el.innerHTML = "Gyroscoper starting..."
    if !navigator
      el.innerHTML = "No navigator"
      return
    if !navigator.compass
      el.innerHTML = "No compass"
      return

    navigator.compass.getCurrentHeading(@getHeadingSuccess, @getHeadingError);    
    el.innerHTML = @getText()
    setTimeout(@start, 2000)
    

  getHeadingSuccess: (heading) ->
    @lastHeading = heading
    @lastError = undefined

  getHeadingError: (error) ->
    @lastError = error
    @lastHeading = undefined

  getText: ->
    return 'Heading: '+@lastHeading.magneticHeading if @lastHeading
    return 'Compass Error (' + error.code + '): ' + error
    return 'No data yet'
