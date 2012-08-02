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
