jQuery = $ = require('jquery')
Tau = require('../tau.coffee').create(jQuery, @)
describe 'Tau', ->

  describe 'turnTurtle', ->
    it 'copies the given turtle with angle increased by the source.angle', ->
      turtle =
        angle: TAU/3
      angle = TAU/6
      expect(Tau.turnTurtle(turtle, angle)).toEqual({angle: 3*TAU/6})

    it 'copies other properties on the turtle without modification', ->
      turtle =
        whatever: 'unchanged'
        angle: 0
      angle = TAU/5
      expect(Tau.turnTurtle(turtle, angle)).toEqual({whatever: 'unchanged', angle: TAU/5})
        
  describe 'moveTurtle', ->
    it 'copies the given turtle with a new position', ->
      turtle =
        x: 25
        y: 15
        angle: @smallest_angle_of_3_4_5_right_triangle
      distance = 50
      result = Tau.moveTurtle(turtle, distance)
      expect(result.x).toBeCloseTo(25 + 40)
      expect(result.y).toBeCloseTo(15 + 30)
      expect(result.angle).toEqual(@smallest_angle_of_3_4_5_right_triangle)

    it 'copies other properties on the turtle without modification', ->
      turtle =
        x: 25
        y: 15
        whatever: 'unchanged'
      distance = 100
      result = Tau.moveTurtle(turtle, distance)
      expect(result.whatever).toEqual('unchanged')

  describe 'drawing', ->
    [context, turtle] = []
    beforeEach () ->
      context = createSpyObj 'context', [
        'beginPath'
        'moveTo'
        'lineTo'
        'stroke'
        'clearRect'
      ]
      context.canvas =
        width: 600
        height: 400
      turtle =
        x: 300
        y: 200
    it 'moveTo positions the given context at the given turtle', ->
      Tau.moveTo context, turtle
      expect(context.beginPath).toHaveBeenCalled()
      expect(context.moveTo).toHaveBeenCalledWith(300, 200)
    it 'lineTo draws a line to the given turtle', ->
      Tau.lineTo context, turtle
      expect(context.lineTo).toHaveBeenCalledWith(300, 200)
      expect(context.stroke).toHaveBeenCalled()
    it 'clearAll clears the entire canvas', ->
      Tau.clearAll context
      expect(context.clearRect).toHaveBeenCalledWith(0, 0, 600, 400)

  describe 'queue', ->
    [Q, enQ, deQ, runQ, emptyQ, first, second] = []
    beforeEach () ->
      Q = []
      enQ = $.proxy Tau.enQ, null, Q
      deQ = $.proxy Tau.deQ, null, Q
      runQ = $.proxy Tau.runQ, null, Q
      emptyQ = $.proxy Tau.emptyQ, null, Q
      first = createSpy 'first'
      second = createSpy 'second'
      enQ(first)

    it 'enQ adds a function to the queue', ->
      expect(Q.length).toEqual(1)
      Q[0]()
      expect(first).toHaveBeenCalled()

    it 'deQ removes a function from the queue', ->
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

    describe 'runQ', () ->
      it 'runs the first item in the queue', () ->
        runQ()
        expect(first).toHaveBeenCalled()
        expect(second).not.toHaveBeenCalled()
      it 'leaves the first item on the queue', () ->
        runQ()
        expect(Q.length).toEqual(1)
        expect(Q[0]).toEqual(first)
      it 'can run the first item on the queue more than once', () ->
        runQ()
        runQ()
        expect(first.calls.length).toEqual 2
      describe 'when the first item from the queue returns Tau.STOP_ITERATION', ->
        beforeEach () ->
          first.andReturn Tau.STOP_ITERATION
          second.andReturn 'the goods'
          enQ(second)
        it 'removes the first item from the queue', ->
          runQ()
          expect(Q.length).toEqual(1)
          expect(Q[0]).toEqual(second)
        it 'runs the second item right away', ->
          expect(runQ()).toEqual('the goods')

    describe 'emptyQ', ->
      it 'removes all the items from the given queue', () ->
        emptyQ()
        expect(Q.length).toEqual(0)
        
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
