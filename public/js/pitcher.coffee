class @Pitcher
  constructor: (opts) ->
    #
    # config
    #

    @options = opts || {}
    default_url = 'audio/horror-drone.wav'
    @volume = 0.07
    @freq = 700 # Hz
    @fade = 0.0

    #
    # audio context
    #

    if typeof webkitAudioContext != "undefined"
      @context = new webkitAudioContext()
    else if typeof AudioContent != "undefined"
      @context = new AudioContext() 
    else
      console.log "AudioContext not supported"
      return

    #
    # gain node (to controle gain/volume)
    #

    @gain = @context.createGain()
    @gain.gain.value = @volume * (1.0 - @fade)
    @gain.connect @context.destination

    #
    # debug
    #

    console.log @context
    console.log @gain

  apply: (value) -> # value assumed to be normalized in the 0.0 to 1.0 range
    # @sound.volume(0.1 + value * 0.9)
    @freq = 300 + 800 * value
    @oscillator.frequency.value = @freq if @oscillator

  start: ->
    return if !@context

    #
    # create and start 
    #
    @oscillator = @context.createOscillator()
    @oscillator.type = 'square'
    @oscillator.frequency.value = @freq 
    @oscillator.connect @gain
    @oscillator.start(@context.currentTime)

  stop: ->
    return if !@oscillator
    @oscillator.stop(@context.currentTime)
    @oscillator = undefined

  toggle: ->
    if @oscillator
      @stop()
    else
      @start()

  setVolume: (vol) ->
    @volume = vol
    @gain.gain.value = vol * (1.0 - @fade) if @gain

  setFade: (fade) ->
    @fade = Math.max(Math.min(fade, 1.0), 0.0)
    @gain.gain.value = @volume * (1.0 - @fade) if @gain
