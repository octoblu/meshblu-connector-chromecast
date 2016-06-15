{job} = require '../../jobs/display-media'

describe 'DisplayMedia', ->
  beforeEach (done) ->
    @player = load: sinon.stub().yields null
    @client = launch: (ignored, callback) => callback null, @player
    @connector = client: @client

    message =
      data:
        media: 'media'
        options: 'options'
    @sut = new job {@connector}
    @sut.do message, done

  it 'should call player.load', ->
    expect(@player.load).to.have.been.calledWith 'media', 'options'
