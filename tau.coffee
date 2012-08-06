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

  _createAngleFromEvent = ($window, event) -> TAU * event.pageX / $window.width()
  _createDistanceFromEvent = ($window, event) ->
    Math.min($window.width(), $window.height()) * event.pageY / $window.height()
  eventHandler = ($window, context, q, event) ->
    angle = _createAngleFromEvent $window, event
    distance = _createDistanceFromEvent $window, event
    turtle =
      x: Math.floor(context.canvas.width / 2)
      y: Math.floor(context.canvas.height / 2)
      angle: 0
    iter = polygonIterator context, turtle, angle, distance
    clearAll context
    emptyQ q
    enQ iter

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
    eventHandler: eventHandler
    _modTau: _modTau
    _createAngleFromEvent: _createAngleFromEvent
    _createDistanceFromEvent: _createDistanceFromEvent