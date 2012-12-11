@Tau ||= Tau = exports ? {}

TAU = 2*Math.PI

extend = (acc, objects...) ->
  acc[key] = object[key] for own key of object for object in objects
  acc

# in javascript angle % TAU will be negative if angle is negative
# using Knuth's floored division instead to ensure angle is always positive
_modTau = (angle) -> angle - Math.floor(angle/TAU)*TAU
__trigFn = (XorY) -> {x: Math.cos, y: Math.sin}[XorY]
__movePartial = (XorY, turtle, distance) -> 
  turtle[XorY] + __trigFn(XorY)(turtle.angle) * distance

Core =
  turn: (turtle, angle) ->
    extend {}, turtle, angle: _modTau turtle.angle + angle
  move: (turtle, distance) ->
    extend {}, turtle,
      x: __movePartial('x', turtle, distance)
      y: __movePartial('y', turtle, distance) 

STOP_ITERATION = -> STOP_ITERATION
Queue =
  STOP_ITERATION: STOP_ITERATION
  enQ: (q, fn) -> q.push fn
  deQ: (q) -> q.shift()
  runQ: (q) ->
    return unless fn = q[0]
    result = fn()
    return result unless result == STOP_ITERATION
    Queue.deQ q
    Queue.runQ q
  emptyQ: (q) -> q.length = 0
  startQ: (q, delay=5) ->
    timer = ->
      Queue.runQ q
      q.timeout = setTimeout timer, delay
    timer()
  stopQ: (q) ->
    clearTimeout(q.timeout)
    delete q.timeout

Context =
  moveTo: (context, turtle) ->
    context.beginPath()
    context.moveTo(turtle.x, turtle.y)
  lineTo: (context, turtle) ->
    context.lineTo(turtle.x, turtle.y)
    context.stroke()
  clearAll: (context) ->
    context.clearRect 0, 0, context.canvas.width, context.canvas.height

extend Tau,
  TAU: TAU
  _modTau: _modTau
  { moveTurtle: Core.move, turnTurtle: Core.turn }
  Queue
  Context

  createDemo: ($) ->
    polygonIterator = (context, turtle, angle, distance, limit=600) ->
      limitExceeded = () -> limit-- <= 0
      moveTo = (turtle) -> Context.moveTo context, turtle
      lineTo = (turtle) -> Context.lineTo context, turtle
      move = (distance) -> turtle = Core.move turtle, distance
      turn = (angle) -> turtle = Core.turn turtle, angle
      () ->
        return STOP_ITERATION if limitExceeded()
        moveTo turtle
        turn angle
        move distance
        lineTo turtle
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
        event = extend {}, touchevent.originalEvent.changedTouches[0], {view: event.view}
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
        Context.clearAll context
        Queue.emptyQ q
        Queue.enQ q, iter

      $document.on 'mousedown', mousedownAdapter(moveHandler)
      $document.on 'touchmove', touchmoveAdapter(moveHandler)
      Tau.startQ q

    polygonIterator: polygonIterator
    createCanvas: createCanvas
    _createAngleFromEvent: _createAngleFromEvent
    _createDistanceFromEvent: _createDistanceFromEvent
