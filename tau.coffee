@create = ($, global) ->
  global.TAU = 2*Math.PI

  # in javascript angle % TAU will be negative if angle is negative
  # using Knuth's floored division instead to ensure angle is always positive
  _modTau = (angle) -> angle - Math.floor(angle/TAU)*TAU
  __trigFn = (sym) -> {x: Math.cos, y: Math.sin}[sym]
  __movePartial = (sym, turtle, source) -> 
    turtle[sym] + __trigFn(sym)(turtle.angle) * source.distance

  turn = (turtle, source) ->
    $.extend {}, turtle, angle: _modTau turtle.angle + source.angle

  move = (turtle, source) ->
    $.extend {}, turtle,
      x: __movePartial('x', turtle, source)
      y: __movePartial('y', turtle, source) 

  Tau =
    info: 'Tau'
    turn: turn
    move: move
    _modTau: _modTau
