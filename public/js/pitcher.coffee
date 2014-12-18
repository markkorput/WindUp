makeDistortionCurve = (amount) ->
  k = typeof amount == 'number' ? amount : 50
  n_samples = 44100
  curve = new Float32Array(n_samples)
  deg = Math.PI / 180
  i = 0
    
  for i in [0..n_samples]
    x = i * 2 / n_samples - 1
    curve[i] = ( 3 + k ) * x * 20 * deg / ( Math.PI + k * Math.abs(x) )

  return curve

class @Pitcher
  constructor: (opts) ->
    #
    # config
    #

    @options = opts || {}
    @track_urls = ['audio/harmonic-drone-repeat.wav', 'audio/techno.wav']
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
    # filters (effect)
    #

    @filter = @context.createBiquadFilter()
    @filter.connect @gain
    @filter.type = @filter.LOWPASS # 'lowpass'; # Low-pass filter. See BiquadFilterNode docs
    @filter.frequency.value = 5000; # Set cutoff to 440 HZ
    @filter.Q.value = 15
    # @filter.gain.value = 25;

    @distortion = @context.createWaveShaper()
    @distortion.curve = makeDistortionCurve(400)
    @distortion.oversample = '4x'
    @distortion.connect @filter

    #
    # BufferSource (track)
    #
    bufferLoader = new BufferLoader @context, @track_urls, (bufferList) =>
      @bufferList = bufferList

    bufferLoader.load()


  apply: (value) -> # value assumed to be normalized in the 0.0 to 1.0 range
    # @sound.volume(0.1 + value * 0.9)
    @freq = 300 + 1600 * value
    # @oscillator.frequency.value = @freq if @oscillator

    # // Clamp the frequency between the minimum value (40 Hz) and half of the
    # // sampling rate.
    minValue = 40
    maxValue = @context.sampleRate / 2;
    # // Logarithm (base 2) to compute how many octaves fall in the range.
    numberOfOctaves = Math.log(maxValue / minValue) / Math.LN2
    # // Compute a multiplier from 0 to 1 based on an exponential scale.
    multiplier = Math.pow(2, numberOfOctaves * (value - 1.0))
    # // Get back to the frequency value between min and max.
    @filter.frequency.value = maxValue * multiplier


    @filter.frequency.value = @freq if @filter
    # @distortion.curve = makeDistortionCurve(100+value * 500) if @distortion

    if @source
      @source.playbackRate.value = 1 + value 

  start: (trck) ->
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

    @stop()

    if trck == 'techno'
      trckidx = 1
    else
      trckidx = 0
    buffer = @bufferList[trckidx]
    @source = @context.createBufferSource()
    @source.buffer = buffer
    @source.loop = true
    @source.connect @filter # @gain
    @source.start(@context.currentTime)

  stop: ->
    if @oscillator
      @oscillator.stop(@context.currentTime) 
      @oscillator = undefined

    if @source
      @source.stop(@context.currentTime)
      @source.disconnect()
      @source = undefined

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
