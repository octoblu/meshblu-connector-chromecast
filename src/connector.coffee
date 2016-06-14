{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-chromecast:index')
{ Client }      = require 'castv2-client'
Discoverer      = require './discoverer'
_               = require 'lodash'
async           = require 'async'

class ChromecastConnector extends EventEmitter
  constructor: (dependencies={}) ->
    {
      Discoverer
      Client
    } = dependencies
    @discoverer = new Discoverer
    debug 'Chromecast constructed'
    @connected = false

  close: (callback) =>
    @client.close()
    process.nextTick callback

  isOnline: (callback) =>
    callback null, running: @connected

  onConfig: (device) =>
    { @options } = device
    @discoverer.discover @options

  _onConnected: (callback) =>
    test = => count > 20 || @connected
    wait = (cb) =>
      debug 'waiting for it to connect'
      count++
      _.delay cb, 500

    async.until test, wait, callback

  _onDiscover: (chromecast) =>
    debug 'discovered'
    @connected = false
    debug 'hello'
    @client = new Client

    @client.on 'error', (error) =>
      console.error 'client error', error if error?
      @connected = false

    @client.connect chromecast.address, (error) =>
      console.error 'client connect error', error if error?
      @connected = true

  start: (device, callback) =>
    { @uuid, @options } = device
    debug 'started', @uuid
    @discoverer.on 'error', (error) =>
      console.error 'discoverer error', error
      @connected = false
      callback error
    @discoverer.on 'discover', @_onDiscover
    @discoverer.discover @options
    @_onConnected callback

module.exports = ChromecastConnector
