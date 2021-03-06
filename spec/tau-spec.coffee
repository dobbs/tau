jQuery = $ = require('jquery')
Tau = require('../tau.coffee')
TAU = Tau.TAU
Demo = Tau.createDemo($)

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
        angle: @smallest_angle_of_3_4_5_triangle
      distance = 50
      result = Tau.moveTurtle(turtle, distance)
      expect(result.x).toBeCloseTo(25 + 40)
      expect(result.y).toBeCloseTo(15 + 30)
      expect(result.angle).toEqual(@smallest_angle_of_3_4_5_triangle)

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
    [Q, enQ, deQ, runQ, emptyQ, startQ, stopQ, first, second] = []
    beforeEach () ->
      Q = []
      [enQ, deQ, runQ, emptyQ, startQ, stopQ] = ($.proxy(fn, null, Q) for fn in [
        Tau.enQ, Tau.deQ, Tau.runQ, Tau.emptyQ, Tau.startQ, Tau.stopQ
      ])
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

      describe 'startQ', ->
        it 'saves the timeout as an attribute on the given Q', () ->
          startQ()
          expect(Q.timeout).toBeDefined()
        it 'calls runQ periodically once started', () ->
          runs () -> startQ(20)
          waits 15
          runs () ->
            expect(first).toHaveBeenCalled()
            expect(first.calls.length).toEqual 1
          waits 40
          runs () ->
            expect(first.calls.length).toEqual 3
          
      describe 'stopQ', ->
        it 'clears the timeout on the given Q', () ->
          startQ()
          stopQ()
          expect(Q.timeout).not.toBeDefined()
        it 'stops calling runQ once stopped', () ->
          runs () -> startQ(20)
          waits 35
          runs () -> stopQ()
          waits 40
          runs () ->
            expect(first).toHaveBeenCalled()
            expect(first.calls.length).toEqual 2

    describe 'emptyQ', ->
      it 'removes all the items from the given queue', () ->
        emptyQ()
        expect(Q.length).toEqual(0)
        
  describe 'polygonIterator', ->
    [context, turtle] = []
    beforeEach () ->
      context = createSpyObj 'context', [
        'beginPath'
        'moveTo'
        'lineTo'
        'stroke'
      ]
      turtle =
        x: 2000
        y: 1000
        angle: 0
    it 'draws segments of a polygon', () ->
      iter = Demo.polygonIterator(context, turtle, @smallest_angle_of_8_15_17_triangle, 170)
      iter()
      expect(context.beginPath).toHaveBeenCalled()
      expect(context.moveTo).toHaveBeenCalledWith(2000, 1000)
      expect(context.lineTo).toHaveBeenCalledWith(2150, 1080)
      expect(context.stroke).toHaveBeenCalled()
    it 'accepts an iteration limit', () ->
      iter = Demo.polygonIterator(context, turtle, @smallest_angle_of_8_15_17_triangle, 170, 3)
      iter()
      iter()
      iter()
      expect(iter()).toEqual(Tau.STOP_ITERATION)
      expect(context.stroke.calls.length).toEqual(3)

  describe 'eventHandler', ->
    [event] = []
    beforeEach () ->
      event =
        pageX: 360
        pageY: 80
        view:
          document:
            body:
              clientWidth: 480
              clientHeight: 320
    it 'calculates a distance to move from the coordinates on the page', ->
      expect(Demo._createDistanceFromEvent(event)).toEqual(80) # 320 * 360/480) 
    it 'calculates an angle to turn from the coordinates on the page', ->
      expect(Demo._createAngleFromEvent(event)).toEqual(TAU*360/480)

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
