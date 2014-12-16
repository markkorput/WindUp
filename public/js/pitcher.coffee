class @Pitcher
  constructor: (opts) ->
    @options = opts || {}

    @sound = new Howl
      urls: ['audio/horror-drone.wav']
      loop: true
      volume: 0.5
      sprite:
        piece1: [3000, 1000]

  start: ->
    console.log 'Starting audio'
    @sound.play('piece1');