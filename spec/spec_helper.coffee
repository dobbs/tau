beforeEach ->
  @addMatchers toRoundTo: (expected, digits = 0) ->
    d = Math.pow(10, digits)
    round = (float) ->
      Math.round(d * float)/d
    round(@actual) is round(expected)
  @smallest_angle_of_3_4_5_right_triangle = Math.asin(3/5)
