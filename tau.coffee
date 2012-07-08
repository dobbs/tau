@create = ($, global) ->
  global.TAU = 2*Math.PI

  # in javascript angle % TAU will be negative if angle is negative
  # using Knuth's floored division instead to ensure angle is always positive
  _modTau = (angle) -> angle - Math.floor(angle/TAU)*TAU

  turn = (turtle, source) ->
    angle = turtle.angle + source.angle
    $.extend({}, turtle, {angle: _modTau(angle)})

  move = (turtle, source) ->
    distance = source.distance
    angle = turtle.angle
    dx = distance * Math.cos(angle)
    dy = distance * Math.sin(angle)
    $.extend({}, turtle, {x: turtle.x + dx, y: turtle.y + dy})

  Tau =
    info: 'Tau'
    turn: turn
    move: move
    _modTau: _modTau