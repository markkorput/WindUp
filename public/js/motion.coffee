class @Motion
  constructor: (opts) ->

    @options = opts || {}
    @outputel = document.getElementById('output')
    @outputel.setAttribute('style', 'display:block;') if @outputel && @options.log == true

    @decay = 0

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

    item = folder.add(data, 'rotation', -1080, 1080)
    item.onChange (val) => @gui_rotation = val
    item.listen()

    folder.add({ResetRot: => @gui_rotation = undefined; data.rotation = 0}, 'ResetRot')
    folder.add({Volume: 0.07}, 'Volume', 0, 0.4).onChange (val) => @pitcher.setVolume(val)

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

  output: (msg) ->

    @msgs ||= []
    @msgs.unshift(msg)
    @msgs.pop() if @msgs.length > 10

    if @outputel && @options.log == true
      @outputel.innerHTML = @msgs.join('\n')

  start: ->
    if @starter
        @starter.parentNode.removeChild(@starter)
        @starter = undefined

    @orienter.start()
    @pitcher.start()

    @two.bind 'update', @update
    @two.play()

  update: (frameCount) =>
    @decay = frameCount * 0.3

    rot = @gui_rotation || @orienter.cumulative
    @output 'Rot: '+ rot + ' ('+@orienter.rotationIndex+')'
    @rotator.rotation = rot / 180 * Math.PI

    value = Math.abs(rot)
    if @decay > value
        value = 0
    else
        value -= @decay
    
    @scaler.scale = value / 270
    @pitcher.apply(Math.min(1.0, value / 1260))


    if value < 90
        @pitcher.setFade(1.0 - value / 90)
    else
        @pitcher.setFade 0.0



