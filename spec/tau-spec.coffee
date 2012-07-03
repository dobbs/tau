Tau = require('../tau.coffee').Tau

describe 'Tau', ->
  it 'has a namespace', ->
    expect(Tau).toBeTruthy()
  it 'defines TAU as 2PI', ->
    expect(TAU).toEqual(2*Math.PI)
