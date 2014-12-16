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

