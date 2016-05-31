{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-chromecast:index')
{ Client }      = require 'castv2-client'
Discoverer      = require './discoverer'
JobRunner       = require './job-runner'
_               = require 'lodash'
async           = require 'async'

class ChromecastConnector extends EventEmitter
  constructor: ->
    debug 'Chromecast constructed'
    @connected = false
    @discoverer = new Discoverer()
    @discoverer.on 'error', (error) =>
      console.error 'discoverer error', error
      @connected = false
    @discoverer.on 'discover', @onDiscover

  close: (callback) =>
    @client.close()

  onDiscover: (chromecast) =>
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

  isOnline: (callback) =>
    callback null, running: @connected

  onMessage: (message={}) =>
    return unless message.payload?
    { metadata, data } = message.payload
    return unless metadata?
    { jobType } = metadata
    return unless jobType?
    debug 'running jobType', jobType
    count = 0
    test = => count > 20 || @connected
    wait = (callback) =>
      debug 'waiting for it to connect'
      count++
      _.delay callback, 500

    async.until test, wait, =>
      runner = new JobRunner { @client, jobType, data }
      runner.do (error) =>
        return console.error 'job error', error if error?
        debug 'ran job', jobType

  onConfig: (device) =>
    { @options } = device
    @discoverer.discover @options

  start: (device) =>
    { @uuid, @options } = device
    debug 'started', @uuid
    @discoverer.discover @options

  close: (callback) =>
    @client?.close()
    callback()

module.exports = ChromecastConnector
