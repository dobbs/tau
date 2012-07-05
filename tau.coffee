@create = ($, global) ->
  global.TAU = 2*Math.PI

  turn = (turtle, source) ->
    angle = turtle.angle + source.angle
    angle -= TAU while angle > TAU
    angle += TAU while angle < 0
    $.extend({}, turtle, {angle: angle})

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
    