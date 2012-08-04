jQuery = require('jquery')
Tau = require('../tau.coffee').create(jQuery, @)
describe 'Tau', ->

  describe 'turn', ->
    it 'copies the given turtle with angle increased by the source.angle', ->
      turtle =
        angle: TAU/3
      source =
        angle: TAU/6
      expect(Tau.turn(turtle, source)).toEqual({angle: 3*TAU/6})

    it 'copies other properties on the turtle without modification', ->
      turtle =
        whatever: 'unchanged'
        angle: 0
      source =
        angle: TAU/5
      expect(Tau.turn(turtle, source)).toEqual({whatever: 'unchanged', angle: TAU/5})
        
  describe 'move', ->
    it 'copies the given turtle with a new position', ->
      turtle =
        x: 25
        y: 15
        angle: @smallest_angle_of_3_4_5_right_triangle
      source =
        distance: 50
      result = Tau.move(turtle, source)
      expect(result.x).toBeCloseTo(25 + 40)
      expect(result.y).toBeCloseTo(15 + 30)
      expect(result.angle).toEqual(@smallest_angle_of_3_4_5_right_triangle)

    it 'copies other properties on the turtle without modification', ->
      turtle =
        x: 25
        y: 15
        whatever: 'unchanged'
      source =
        distance: 100
      result = Tau.move(turtle, source)
      expect(result.whatever).toEqual('unchanged')

  describe 'smoke tests', ->
    it 'has a namespace', ->
      expect(Tau).toBeTruthy()
    it 'defines TAU as 2PI', ->
      expect(TAU).toEqual(2*Math.PI)

  describe 'internals', ->
    describe '_modTau', ->
      it 'calculates angle % TAU where result is always a positive fraction of TAU', ->
        expect(Tau._modTau(given)).toBeCloseTo(expected,7) for [given, expected] in [
          [TAU/4, TAU/4]
          [5*TAU/4, TAU/4]
          [41*TAU/4, TAU/4]
          [-TAU/3, 2*TAU/3]
          [-4*TAU/3, 2*TAU/3]
          [-31*TAU/3, 2*TAU/3]
        ]
    describe 'x1 = _moveX(x0, angle, distance)', ->
      it 'calculates x1 when x0 is the origin', ->
        expect(Tau._moveX(0, angle, 50)).toBeCloseTo(expected) for [angle, expected] in [
          [0, 50]
          [TAU/2, -50]
          [-TAU/4, 0]
          [TAU/4, 0]
          [@smallest_angle_of_3_4_5_right_triangle, 40]
        ]
      it 'calculates x1 when x0 is not the origin', ->
        expect(Tau._moveX(20, angle, 50)).toBeCloseTo(expected) for [angle, expected] in [
          [0, 70]
          [TAU/2, -30]
          [-TAU/4, 20]
          [TAU/4, 20]
          [@smallest_angle_of_3_4_5_right_triangle, 60]
        ]
    describe 'y1 = _moveY(y0, angle, distance)', ->
      it 'calculates y1 when y0 is the origin', ->
        expect(Tau._moveY(0, angle, 50)).toBeCloseTo(expected) for [angle, expected] in [
          [0, 0]
          [TAU/2, 0]
          [-TAU/4, -50]
          [TAU/4, 50]
          [@smallest_angle_of_3_4_5_right_triangle, 30]
        ]
      it 'calculates y1 when y0 is not the origin', ->
        expect(Tau._moveY(-30, angle, 50)).toBeCloseTo(expected) for [angle, expected] in [
          [0, -30]
          [TAU/2, -30]
          [-TAU/4, -80]
          [TAU/4, 20]
          [@smallest_angle_of_3_4_5_right_triangle, 0]
        ]

