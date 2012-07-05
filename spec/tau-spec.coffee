jQuery = require('jquery')
Tau = require('../tau.coffee').create(jQuery, @)
describe 'Tau', ->

  describe 'smoke tests', ->
    it 'has a namespace', ->
      expect(Tau).toBeTruthy()
    it 'defines TAU as 2PI', ->
      expect(TAU).toEqual(2*Math.PI)

  describe 'turn', ->
    it 'copies the given turtle with angle increased by the source.angle', ->
      turtle =
        angle: TAU/3
      source =
        angle: TAU/6
      expect(Tau.turn(turtle, source)).toEqual({angle: 3*TAU/6})

    it 'converts negative angles in the source to equivalent positive angle', ->
      turtle =
        angle: 0
      source =
        angle: -TAU/4
      expect(Tau.turn(turtle, source).angle).toRoundTo(3*TAU/4, 7)

    it 'converts angle > TAU in the source to the equivalent fraction of TAU', ->
      turtle =
        angle: 0
      source =
        angle: 4*TAU/3
      expect(Tau.turn(turtle, source).angle).toRoundTo(TAU/3, 7)

    it 'does not interfere with other properties on the turtle', ->
      turtle =
        whatever: 'unchanged'
        angle: 0
      source =
        angle: TAU/5
      expect(Tau.turn(turtle, source)).toEqual({whatever: 'unchanged', angle: TAU/5})
        
  describe 'move', ->
    it 'somethings', ->
      turtle =
        x: 0
        y: 0
        angle: @smallest_angle_of_3_4_5_right_triangle
      source =
        distance: 50
      result = Tau.move(turtle, source)
      expect(result.x).toRoundTo(40)
      expect(result.y).toRoundTo(30)
      expect(result.angle).toEqual(@smallest_angle_of_3_4_5_right_triangle)