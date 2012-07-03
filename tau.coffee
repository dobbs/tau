do
  ->
    @$ = require('jquery').create()
    @TAU = 2*Math.PI

  turn = (turtle, source) ->
    angle = turtle.angle + source.angle
    angle -= TAU while angle > TAU
    angle += TAU while angle < 0
    $.extend({}, turtle, {angle: angle})

  @Tau =
    info: 'Tau'
    turn: turn