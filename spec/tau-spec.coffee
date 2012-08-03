jQuery = $ = require('jquery')
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

  describe 'queue', ->
    [Q, enQ, deQ, first, second] = []
    beforeEach () ->
      Q = []
      enQ = $.proxy Tau.enqueue, null, Q
      deQ = $.proxy Tau.dequeue, null, Q
      first = createSpy 'first'
      second = createSpy 'second'
      enQ(first)

    it 'enqueue adds a function to the queue', ->
      expect(Q.length).toEqual(1)
      Q[0]()
      expect(first).toHaveBeenCalled()

    it 'dequeue removes a function from the queue', ->
      deQ()
      expect(Q.length).toEqual(0)

    describe 'first in, first out', ->
      it 'removes items from the queue in the same order they were entered', ->
        enQ(second)
        deQ()()
        expect(first).toHaveBeenCalled()
        expect(second).not.toHaveBeenCalled()
        deQ()()
        expect(second).toHaveBeenCalled()
      it 'returns undefined when the queue is empty', ->
        deQ()
        expect(deQ()).toBeUndefined()

    describe 'runqueue', () ->
      runQ = undefined
      beforeEach () -> runQ = $.proxy Tau.runqueue, null, Q
      it 'runs the first item in the queue', () ->
        runQ()
        expect(first).toHaveBeenCalled()
        expect(second).not.toHaveBeenCalled()
      it 'leaves the first item on the queue', () ->
        runQ()
        expect(Q.length).toEqual(1)
        expect(Q[0]).toEqual(first)
      describe 'when the first item from the queue throws Tau.STOP_ITERATION', ->
        beforeEach () ->
          first.andThrow Tau.STOP_ITERATION
          second.andReturn 'the goods'
          enQ(second)
        it 'removes the first item from the queue', ->
          expect(runQ).not.toThrow(Tau.STOP_ITERATION)
          expect(Q.length).toEqual(1)
          expect(Q[0]).toEqual(second)
        it 'runs the second item right away', ->
          expect(runQ()).toEqual('the goods')
        
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
