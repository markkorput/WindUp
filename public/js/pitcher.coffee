class @Pitcher
  constructor: (opts) ->
    #
    # config
    #

    @options = opts || {}
    @track_url = 'audio/jam.wav'
    @volume = 0.4
    @freq = 700 # Hz
    @gainMultiplier = 1.0

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
    @gain.gain.value = @volume * @gainMultiplier
    @gain.connect @context.destination

    #
    # filter (effect)
    #

    @filter = @context.createBiquadFilter()
    @filter.connect @gain
    @filter.type = 'lowpass'; # Low-pass filter. See BiquadFilterNode docs
    @filter.frequency.value = 440; # Set cutoff to 440 HZ

    #
    # BufferSource (track)
    #
    bufferLoader = new BufferLoader @context, [@track_url], (bufferList) =>
      @bufferList = bufferList

    bufferLoader.load()

    #
    # debug
    #

    console.log @context
    console.log @gain

  apply: (value) -> # value assumed to be normalized in the 0.0 to 1.0 range
    # @sound.volume(0.1 + value * 0.9)
    @freq = 300 + 1600 * value
    @oscillator.frequency.value = @freq if @oscillator
    @filter.frequency.value = @freq if @filter

  start: ->
    return if !@context

    #
    # create and start 
    #

    # for i in [0..1]
    #   @oscillator = @context.createOscillator()
    #   @oscillator.type = 'square'
    #   @oscillator.frequency.value = @freq + i*10
    #   @oscillator.connect @gain
    #   # @oscillator.start(@context.currentTime)

    for buffer in @bufferList
      @source = @context.createBufferSource()
      @source.buffer = buffer
      
      @source.loop = true
      @source.connect @filter # @gain
      console.log @source
      @source.start(@context.currentTime) if @source

    

  stop: ->
    if @oscillator
      @oscillator.stop(@context.currentTime) 
      @oscillator = undefined

    if @source
      @source.stop(@context.currentTime)

  toggle: ->
    if @oscillator
      @stop()
    else
      @start()

  setVolume: (vol) ->
    @volume = vol
    @gain.gain.value = vol * (1.0 - @fade) if @gain

  setGain: (g) ->
    @gainMultiplier = Math.max(Math.min(g, 1.0), 0.0)
    @gain.gain.value = @volume * @gainMultiplier if @gain
