class @Motion
  constructor: (opts) ->

    @options = opts || {}
    @outputel = document.getElementById('output')
    @outputel.setAttribute('style', 'display:block;') if @outputel && @options.log == true

    @levelBase = 900 + Math.random() * 100
    @level = @levelBase
    @decaySpeed = -25 - Math.random() * 5
    @rotSpeed = 0.9 + Math.random() * 0.2

    #
    # Modules
    #

    @orienter = new Orienter()
    @pitcher = new Pitcher()

    #
    # Visuals
    #

    @radius = 50

    @twoEl = document.getElementById('motion-anim');
    @two = new Two(fullscreen: true).appendTo(@twoEl)

    @circle = @two.makeCircle(0,0, @radius)    
    @circle.fill = '#FF8000'
    @circle.stroke = 'orangered'
    @circle.linewidth = 5;

    @c = @two.makeCircle(0, -@radius - 30, 20)
    @c.fill = '#0080FF'
    @c.stroke = 'blue'
    @c.linewidth = 3;

    @rotator = @two.makeGroup(@c)
    # @rotator.translation.set(@two.width/2, @two.height/2)

    @scaler = @two.makeGroup(@circle, @rotator)
    @scaler.translation.set(@two.width/2, @two.height/2)

    #
    # GUI
    #

    @gui = new dat.GUI()
    data = new ->
      @rotation = 0
      @audio = true

    folder = @gui.addFolder 'Params'
    folder.open()

    item = folder.add(data, 'audio')
    item.onChange (val) =>
      @pitcher.toggle()

    item = folder.add(data, 'rotation', -2000, 2000)
    item.onChange (val) => @gui_rotation = val
    item.listen()

    folder.add({ResetRot: => @gui_rotation = undefined; data.rotation = 0}, 'ResetRot')
    folder.add({Volume: 0.07}, 'Volume', 0, 0.3).onChange (val) => @pitcher.setVolume(val)
    folder.add({DecaySpeed: @decaySpeed}, 'DecaySpeed', -100, 100).onChange (val) => @decaySpeed = val

    #
    # For development reference console.log some stuff
    #

    console.log @two
    console.log @circle
    console.log @gui

    # iOS safari requires sound to be started in a touchEvent callback situation
    @starter = document.getElementById('starter')
    @starter.addEventListener "click", => @start()
    @starter.addEventListener "touchstart", => @start()

    # document.addEventListener "deviceready", => @start()

  output: (msg) ->

    @msgs ||= []
    @msgs.unshift(msg)
    @msgs.pop() if @msgs.length > 10

    if @outputel && @options.log == true
      @outputel.innerHTML = @msgs.join('\n')

  start: ->
    @startTime = new Date().getTime() * 0.001

    if @starter
        @starter.parentNode.removeChild(@starter)
        @starter = undefined

    @orienter.start()
    @pitcher.start()

    @two.bind 'update', @update
    @two.play()

  update: (frameCount) =>
    thisFrameTime = new Date().getTime() * 0.001
    deltaTime = thisFrameTime - (@lastFrameTime || thisFrameTime)
    @lastFrameTime = thisFrameTime # for next frame

    thisFrameRot = @gui_rotation || @orienter.cumulative
    deltaRot = thisFrameRot - (@lastFrameRot || 0)
    @lastFrameRot = thisFrameRot # for next frame

    decay = @decaySpeed * deltaTime # decay since last frame
    rot = @rotSpeed * deltaRot # rotation score since last frame

    @level = Math.abs(Math.max(0.0, @level + decay) + rot)
    # console.log decay, rot, @level

    # update visuals/audio; scale, rotate and pitch
    @rotator.rotation = thisFrameRot / 180 * Math.PI
    @scaler.scale = @level / 270
    @pitcher.apply(Math.min(1.0, @level / 1260))

    # fade-out for level 0-90 (degrees, really)
    if @level < 90
        @pitcher.setFade(1.0 - @level / 90)
    else
        @pitcher.setFade 0.0

    @output 'Lvl: ' + @level + ' / Rot: ' + thisFrameRot


