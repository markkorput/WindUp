class @Motion
  constructor: (opts) ->

    @options = opts || {}
    @outputel = document.getElementById('output')
    @outputel.setAttribute('style', 'display:block;') if @outputel && @options.log == true

    @minLevel = 0
    @maxLevel = 1500
    @levelBase = (@maxLevel + @minLevel) / 2 # 900 + Math.random() * 100
    @level = @levelBase
    @levelGainer = 0.01
    @decaySpeed = 0 # 5 - Math.random() * 10
    @rotSpeed = 0.9 + Math.random() * 0.2
    @gainSineSpeed = 0 # 50 + Math.random()*5

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
    folder.add({Reset: => 
        @level = @levelBase
        @pitcher.start()
        @pitcher.setVolume 0.4
        @decaySpeed = 0
        @rotSpeed = 0.9 + Math.random() * 0.2
    }, 'Reset')

    # dat.GUI.toggleHide();

    #
    # For development reference console.log some stuff
    #

    # console.log @two
    # console.log @circle
    # console.log @gui

    # iOS safari requires sound to be started in a touchEvent callback situation
    @starter = document.getElementById('starter')
    @starter.addEventListener "click", => @start()
    @starter.addEventListener "touchstart", => @start()

    # document.addEventListener "deviceready", => @start()

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

    if @level < 0.2
        # make it easy for the user to get out of the zero-level;
        # don't apply decay while at zero
        decay = 0
        # rotating in any direction will cause increase of level
        if rot < 0
            rot = -rot
            @rotSpeed *= -1 # reverse increase/decrease rotation-directions

    @level = Math.min(Math.abs(Math.max(@minLevel, @level + decay) + rot), @maxLevel)
    deltaLevel = @level - @levelBase

    # console.log decay, rot, @level

    # update visuals/audio; scale, rotate and pitch
    @rotator.rotation = thisFrameRot / 180 * Math.PI
    @scaler.scale = @level / 270
    apply = 1 + deltaLevel / (@maxLevel - @levelBase)
    @output 'Apply: ' + apply
    @pitcher.apply apply

    if @gainSineSpeed < 10
        gain = 1.0
    else
        gain = Math.sin(thisFrameTime*@gainSineSpeed)

    # fade-out for level 0-90 (degrees, really)
    if @level < 90
        gain = Math.min(gain, @level / 90)
    @pitcher.setGain(gain > 0.1 ? 1.0 : 0.0)

    if frameCount % 15 == 0
        @output 'Lvl: ' + @level + ' / Rot: ' + thisFrameRot


