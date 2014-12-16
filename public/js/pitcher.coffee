class @Pitcher
  constructor: (opts) ->
    @options = opts || {}

    @sound = new Howl
      urls: ['audio/horror-drone.wav']
      loop: true
      volume: 0.5
      sprite:
        piece1: [3000, 1000]

    @isPlaying = false

  start: ->
    @sound.play('piece1');
    @isPlaying = true

  stop: ->
    @sound.stop()
    @isPlaying = false

  toggle: ->
    if @isPlaying == true
      @stop()
    else
      @start()

  apply: (value) -> # value assumed to be normalized in the 0.0 to 1.0 range
    @sound.volume(0.1 + value * 0.9)
