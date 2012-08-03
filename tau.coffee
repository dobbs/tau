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
    try
      fn()
    catch e
      throw e unless e == STOP_ITERATION
      deQ q
      runQ q

  Tau =
    STOP_ITERATION: STOP_ITERATION
    info: 'Tau'
    turnTurtle: turnTurtle
    moveTurtle: moveTurtle
    enQ: enQ
    deQ: deQ
    runQ: runQ
    _modTau: _modTau
