{EventEmitter}  = require 'events'
Discoverer = require '../src/discoverer'
Chromecast = require '../'

describe 'Chromecast', ->
  beforeEach ->
    @discoverer = new Discoverer
    @discoverer.on = sinon.stub()
    FakeDiscoverer = => @discoverer
    Client = class Client

    @sut = new Chromecast {Discoverer: FakeDiscoverer, Client}
    {@discoverer} = @sut

  describe '->start', ->
    beforeEach ->
      @discoverer.discover = sinon.stub()

    describe 'when called with nothing', ->
      it 'should throw an error', ->
        expect(=> @sut.start()).to.throw(Error)

    describe 'when called with a device', ->
      beforeEach ->
        device =
          uuid: 'hello'
          options: foo: 'bar'
        try
          @sut.start device
        catch error
          @error = error

      it 'should not throw an error', ->
        expect(@error).not.to.exist

      it 'should call discover', ->
        expect(@discoverer.discover).to.have.been.calledWith foo: 'bar'

  describe '->isOnline', ->
    it 'should be a method', ->
      expect(@sut.isOnline).to.be.a 'function'

    it 'should yield running true', (done) ->
      @sut.isOnline (error, response) =>
        return done error if error?
        expect(response.running).to.be.false
        done()

  describe '->close', ->
    it 'should be a method', ->
      expect(@sut.close).to.be.a 'function'

    it 'should yield when called', (done) ->
      @sut.close => done()

  describe '->onMessage', ->
    it 'should be a method', ->
      expect(@sut.onMessage).to.be.a 'function'

    describe 'when called with a message', ->
      it 'should not throw an error', ->
        expect(=> @sut.onMessage({ topic: 'hello', devices: ['123'] })).to.not.throw(Error)

  describe '->onConfig', ->
    it 'should be a method', ->
      expect(@sut.onConfig).to.be.a 'function'

    describe 'when called with a config', ->
      it 'should not throw an error', ->
        expect(=> @sut.onConfig { type: 'hello' }).to.not.throw(Error)
