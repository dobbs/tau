@create = ($, global) ->
  global.TAU = 2*Math.PI

  # in javascript angle % TAU will be negative if angle is negative
  # using Knuth's floored division instead to ensure angle is always positive
  _modTau = (angle) -> angle - Math.floor(angle/TAU)*TAU
  __movePartial = (trigFn) -> (p, angle, distance) -> p + trigFn(angle) * distance
  _moveX = __movePartial Math.cos
  _moveY = __movePartial Math.sin

  turn = (turtle, source) ->
    $.extend {}, turtle, angle: _modTau turtle.angle + source.angle

  move = (turtle, source) ->
    $.extend {}, turtle,
      x: _moveX(turtle.x, turtle.angle, source.distance)
      y: _moveY(turtle.y, turtle.angle, source.distance)

  Tau =
    info: 'Tau'
    turn: turn
    move: move
    _modTau: _modTau
    _moveX: _moveX
    _moveY: _moveY