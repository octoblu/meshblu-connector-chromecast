{job} = require '../../jobs/display-media'

describe 'DisplayMedia', ->
  beforeEach (done) ->
    @player =
      load: sinon.stub()
    @client =
      launch: sinon.stub().yields null, @player
    @connector =
      client: @client

    message =
      data:
        media: {}
        options: {}
    @sut = new job {@connector}
    @sut.do message, done

  it 'should call player.load', ->
    expect(@player.load).to.have.been.calledWith {}, {}
