{job} = require '../../jobs/display-media'

describe 'DisplayMedia', ->
  beforeEach ->
    @sut = new job {@connector}

  it 'should exist', ->
    expect(@sut).to.exist
