{EventEmitter}  = require 'events'
Chromecast = require '../'

describe 'Chromecast', ->
  beforeEach (done) ->
    class FakeClient
      on: =>
      connect: (ignored, callback) =>
        @connected = true
        callback()

      close: =>

    @sut = new Chromecast {Client: FakeClient}
    {@discoverer} = @sut
    @discoverer.discover = (options) =>
      setTimeout (=> @discoverer.emit 'discover', {}), 100

    @sut.start {}, done

  afterEach (done) ->
    @sut.close done

  it 'should work', (done) ->
    @sut.isOnline (error, {running}) =>
      return done error if error?
      expect(running).to.be.true
      done()

  describe '->onConfig', ->
    beforeEach (done) ->
      @discoverer.discover = (options) =>
        @discoverer.emit 'discover', {}
        done()
      @sut.onConfig {}

    it 'should work', (done) ->
      @sut.isOnline (error, {running}) =>
        return done error if error?
        expect(running).to.be.true
        done()
