class @Pitcher
  constructor: (opts) ->
    #
    # config
    #

    @options = opts || {}
    default_url = 'audio/horror-drone.wav'
    @volume = 0.2
    @freq = 700

    #
    # audio context
    #

    if typeof AudioContent != "undefined"
      @context = new AudioContext()
    else if typeof webkitAudioContext != "undefined"
      @context = new webkitAudioContext()
    else
      console.log "AudioContext not supported"
      return

    #
    # gain node (to controle gain/volume)
    #

    @gain = @context.createGain()
    @gain.gain.value = @volume
    @gain.connect @context.destination

    #
    # debug
    #

    console.log @context
    console.log @gain

  apply: (value) -> # value assumed to be normalized in the 0.0 to 1.0 range
    # @sound.volume(0.1 + value * 0.9)
    @freq = 300 + 800 * value
    @oscillator.frequency.value = @freq

  start: ->
    #
    # create and start 
    #
    @oscillator = @context.createOscillator()
    @oscillator.type = 'square'
    @oscillator.frequency.value = @freq # Hz
    @oscillator.connect @gain
    @oscillator.start(@context.currentTime)

  stop: ->
    @oscillator.stop(@context.currentTime)
    @oscillator = undefined

  toggle: ->
    if @oscillator
      @stop()
    else
      @start()

  setVolume: (vol) ->
    @volume = vol
    @gain.gain.value = vol