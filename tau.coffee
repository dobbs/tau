@create = ($, global) ->
  global.TAU = 2*Math.PI

  # in javascript angle % TAU will be negative if angle is negative
  # using Knuth's floored division instead to ensure angle is always positive
  _modTau = (angle) -> angle - Math.floor(angle/TAU)*TAU
  __trigFn = (XorY) -> {x: Math.cos, y: Math.sin}[XorY]
  __movePartial = (XorY, turtle, source) -> 
    turtle[XorY] + __trigFn(XorY)(turtle.angle) * source.distance

  turn = (turtle, source) ->
    $.extend {}, turtle, angle: _modTau turtle.angle + source.angle

  move = (turtle, source) ->
    $.extend {}, turtle,
      x: __movePartial('x', turtle, source)
      y: __movePartial('y', turtle, source) 

  enqueue = (queue, fn) -> queue.unshift fn

  dequeue = (queue) -> queue.pop()

  Tau =
    info: 'Tau'
    turn: turn
    move: move
    enqueue: enqueue
    dequeue: dequeue
    _modTau: _modTau
