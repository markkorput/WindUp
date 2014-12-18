class @Motion
  constructor: (opts) ->

    @options = opts || {}
    @outputel = document.getElementById('output')
    @outputel.setAttribute('style', 'display:block;') if @outputel && @options.log == true

    @minLevel = 0
    @maxLevel = 1500
    @levelBase = (@maxLevel + @minLevel) / 2 # 900 + Math.random() * 100
    @level = @levelBase
    @levelGainer = 0.5
    @decaySpeed = 20 + Math.random() * 10
    @decaySpeed = @decaySpeed * -1 if Math.random() > 0.5
    @rotSpeed = 0.9 + Math.random() * 0.2
    @gainSineSpeed = 0 # 50 + Math.random()*5
    @mode = 'steady'
    console.log 'decay speed:', @decaySpeed
    #
    # Modules
    #

    @orienter = new Orienter()
    @pitcher = new Pitcher()
    # @accel = new Accelerometer()


    #
    # Visuals
    #

    @radius = 1000

    @twoEl = document.getElementById('motion-anim');
    @two = new Two(fullscreen: true).appendTo(@twoEl)

    @baseR = parseInt 100 + Math.random() * 120
    @baseG = parseInt 100 + Math.random() * 100
    @baseB = parseInt 100 + Math.random() * 80

    @rFactor = 15 + Math.random() * 60
    @gFactor = 15 + Math.random() * 80
    @bFactor = 15 + Math.random() * 100

    @circle = @two.makeCircle(0,0, @radius)    
    clr = 'rgb('+@baseR+','+@baseG+','+@baseG+')'
    @circle.fill = clr # '#FF8000'
    # @circle.stroke = 'orangered'
    # @circle.linewidth = 5;
    @circle.noStroke()

    @c = @two.makeCircle(0, -@radius * 0.9, 20)
    @c.fill = '#0080FF'
    # @c.stroke = 'blue'
    # @c.linewidth = 3;
    @c.noStroke()


    window.two = @two
    @spiral = window.makeSpiral()
    @spiral.stroke = 'white'
    @spiral.linewidth = 7
    # @spiral.fill = clr
    @spiral.noFill()

    @rotator = @two.makeGroup(@spiral)
    # @rotator.translation.set(@two.width/2, @two.height/2)

    @scaler = @two.makeGroup(@circle, @rotator) # , @rotator)
    @scaler.translation.set(@two.width/2, @two.height/2)

    #
    # For development reference console.log some stuff
    #

    # console.log @two
    # console.log @circle
    # console.log @gui

    # iOS safari requires sound to be started in a touchEvent callback situation
    @starter = document.getElementById('starter')
    @restarter = document.getElementById('restarter')
    @starter.addEventListener "click", => @start()
    @starter.addEventListener "touchstart", => @start()

    # document.addEventListener "deviceready", => @start()


    # return # skip
    #
    # GUI
    #

    @gui = new dat.GUI()
    folder = @gui.addFolder 'Params'
    folder.open()

    folder.add({track: 'drone'}, 'track', {'drums': 0, 'dj': 1, 'electro': 2, 'mute': -1}).onChange (val) =>
        if val == -1
            @pitcher.stop()
        else
            @pitcher.start(val)

    folder.add({rotation: 0}, 'rotation', -2000, 2000).onChange (val) => @gui_rotation = val
    folder.add({ResetRot: => @gui_rotation = undefined; }, 'ResetRot')
    folder.add({Volume: @pitcher.volume}, 'Volume', 0, 0.8).onChange (val) => @pitcher.setVolume(val)
    folder.add({DecaySpeed: @decaySpeed}, 'DecaySpeed', -30, 30).onChange (val) => @decaySpeed = val
    folder.add({RotSpeed: @rotSpeed}, 'RotSpeed', -5, 5).onChange (val) => @rotSpeed = val
    folder.add({GainSine: @gainSineSpeed}, 'GainSine', 0, 300).onChange (val) => @gainSineSpeed = val
    # folder.add({mode: @mode}, 'mode', ['steady', 'generator']).onChange (val) => @mode = val
    folder.add({Reset: => @restart()}, 'Reset')


    # dat.GUI.toggleHide();

  output: (msg) ->
    return if !@outputel || @options.log != true

    @msgs ||= []
    @msgs.unshift(msg)
    @msgs.pop() if @msgs.length > 5
    @outputel.innerHTML = @msgs.join('\n')

  start: ->

    if !@pitcher || !@pitcher.bufferList
        console.log 'not ready'
        return

    @startTime = new Date().getTime() * 0.001

    if @starter
        @starter.parentNode.removeChild(@starter)
        @starter = undefined

    if @restarter
        @restarter.setAttribute('style', 'display:block;');
        @restarter.addEventListener "click", => @restart()
        @restarter.addEventListener "touchstart", => @restart()

    @orienter.start()
    @pitcher.start()
    # @accel.start()

    @two.bind 'update', @update
    @two.play()

  restart: ->
    @level = @levelBase
    @pitcher.start()
    @pitcher.setVolume 0.4
    # @decaySpeed = 0
    @rotSpeed = 0.9 + Math.random() * 0.2
    @decaySpeed = 30 + Math.random() * 10
    @decaySpeed = @decaySpeed * -1 if Math.random() > 0.5

  update: (frameCount) =>
    thisFrameTime = new Date().getTime() * 0.001
    deltaTime = thisFrameTime - (@lastFrameTime || thisFrameTime)
    @lastFrameTime = thisFrameTime # for next frame

    thisFrameRot = @gui_rotation || @orienter.cumulative
    deltaRot = thisFrameRot - (@lastFrameRot || 0)
    @lastFrameRot = thisFrameRot # for next frame

    decay = @decaySpeed * deltaTime # decay since last frame
    rot = @rotSpeed * deltaRot # rotation score since last frame

    if @level < 0.2
        # make it easy for the user to get out of the zero-level;
        # don't apply decay while at zero
        decay = 0
        # rotating in any direction will cause increase of level
        if rot < 0
            rot = -rot
            @rotSpeed *= -1 # reverse increase/decrease rotation-directions

    if deltaRot > 20
        decay = 0
    else
        decay = decay * Math.abs(deltaRot) / 20

    # console.log 'deltaRot: ' + deltaRot
    @level = Math.min(Math.abs(Math.max(@minLevel, @level + decay) + rot), @maxLevel)
    deltaLevel = @level - @levelBase


    # update visuals/audio; scale, rotate and pitch
    @rotator.rotation += deltaRot * 0.002 + @level * 0.0001
    # @scaler.scale = @level / 270

    maxDeltaLevel = (@maxLevel - @levelBase)
    factor = (@level / maxDeltaLevel + Math.sin(thisFrameTime * 10 + @level * 0.0001)*0.2)
    r = parseInt @baseR + factor * @rFactor
    g = parseInt @baseG + factor * @bFactor
    b = parseInt @baseB + factor * @gFactor
    clr = 'rgb('+r+','+g+','+b+')'
    @circle.fill = clr




    if @gainSineSpeed < 10
        gain = 1.0
    else
        gain = Math.sin(thisFrameTime*@gainSineSpeed)


    if @mode == 'steady'
        apply = 1 + deltaLevel / maxDeltaLevel
    else
        if deltaRot < 0.1
            gain = 0.0
        apply = Math.max(2.0, Math.min(0.2, deltaRot * 0.01))

    @pitcher.apply apply


    # fade-out for level 0-90 (degrees, really)
    if @level < 90
        gain = Math.min(gain, @level / 90)
    @pitcher.setGain(gain > 0.1 ? 1.0 : 0.0)

    if frameCount % 15 == 0
        # @output deltaRot
        @output 'Lvl: ' + @level + ' / Rot: ' + thisFrameRot


