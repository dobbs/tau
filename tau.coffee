@create = ($, global) ->
  STOP_ITERATION = () -> STOP_ITERATION
  global.TAU = 2*Math.PI

  # in javascript angle % TAU will be negative if angle is negative
  # using Knuth's floored division instead to ensure angle is always positive
  _modTau = (angle) -> angle - Math.floor(angle/TAU)*TAU
  __trigFn = (XorY) -> {x: Math.cos, y: Math.sin}[XorY]
  __movePartial = (XorY, turtle, distance) -> 
    turtle[XorY] + __trigFn(XorY)(turtle.angle) * distance

  turnTurtle = (turtle, angle) ->
    $.extend {}, turtle, angle: _modTau turtle.angle + angle

  moveTurtle = (turtle, distance) ->
    $.extend {}, turtle,
      x: __movePartial('x', turtle, distance)
      y: __movePartial('y', turtle, distance) 

  enQ = (q, fn) -> q.push fn
  deQ = (q) -> q.shift()
  runQ = (q) ->
    return unless fn = q[0]
    result = fn()
    return result unless result == STOP_ITERATION
    deQ q
    runQ q
  emptyQ = (q) -> q.length = 0
  startQ = (q, delay=5) ->
    timer = () ->
      runQ q
      q.timeout = setTimeout timer, delay
    timer()
  stopQ = (q) ->
    clearTimeout(q.timeout)
    delete q.timeout

  moveTo = (context, turtle) ->
    context.beginPath()
    context.moveTo(turtle.x, turtle.y)
  lineTo = (context, turtle) ->
    context.lineTo(turtle.x, turtle.y)
    context.stroke()
  clearAll = (context) ->
    context.clearRect 0, 0, context.canvas.width, context.canvas.height

  polygonIterator = (context, turtle, angle, distance, limit=600) ->
    limitExceeded = () -> limit-- <= 0
    () ->
      return STOP_ITERATION if limitExceeded()
      moveTo context, turtle
      turtle = turnTurtle turtle, angle
      turtle = moveTurtle turtle, distance
      lineTo context, turtle
      turtle

  _widthFromEvent = (event) -> event.view.document.body.clientWidth
  _heightFromEvent = (event) -> event.view.document.body.clientHeight
  _createAngleFromEvent = (event) -> TAU * event.pageX / _widthFromEvent(event)
  _createDistanceFromEvent = (event) ->
    w = _widthFromEvent event
    h = _heightFromEvent event
    Math.min(w, h) * event.pageY / h

  touchmoveAdapter = (moveHandler) ->
    (touchevent) ->
      touchevent.preventDefault()
      event = $.extend({}, touchevent.originalEvent.changedTouches[0], {view: event.view})
      moveHandler(event)
    
  mousedownAdapter = (moveHandler) ->
    (event) ->
      doc = event.view.document
      $(doc)
        .on('mousemove', moveHandler)
        .on('mouseup', (e) -> $(e.view.document).off('mousemove', moveHandler))

  createCanvas = ($window, q) ->
    width = $window.width() - 20
    height = $window.height() - 20
    $canvas = $("<canvas width=\"#{width}\" height=\"#{height}\">")
    context = $canvas[0].getContext('2d')
    $document = $($window[0].document)
    $document.find('body').append($canvas)

    moveHandler = (event) ->
      width = _widthFromEvent event
      height = _heightFromEvent event
      angle = _createAngleFromEvent event
      distance = _createDistanceFromEvent event
      turtle =
        x: Math.floor(width / 2)
        y: Math.floor(height / 2)
        angle: 0
      iter = polygonIterator context, turtle, angle, distance
      clearAll context
      emptyQ q
      enQ q, iter

    $document.on 'mousedown', mousedownAdapter(moveHandler)
    $document.on 'touchmove', touchmoveAdapter(moveHandler)
    startQ q

  Tau =
    STOP_ITERATION: STOP_ITERATION
    info: 'Tau'
    turnTurtle: turnTurtle
    moveTurtle: moveTurtle
    moveTo: moveTo
    lineTo: lineTo
    clearAll: clearAll
    enQ: enQ
    deQ: deQ
    runQ: runQ
    emptyQ: emptyQ
    startQ: startQ
    stopQ: stopQ
    polygonIterator: polygonIterator
    createCanvas: createCanvas
    _modTau: _modTau
    _createAngleFromEvent: _createAngleFromEvent
    _createDistanceFromEvent: _createDistanceFromEvent