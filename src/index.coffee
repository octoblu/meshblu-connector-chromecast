{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-chromecast:index')
{
  Client,
  DefaultMediaReceiver,
} = require 'castv2-client'
Discoverer      = require './discoverer'
JobRunner       = require './job-runner'

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

  onMessage: (message) =>
    { topic, devices, fromUuid } = message
    return if '*' in devices
    return if fromUuid == @uuid
    { metadata, data } = message
    return unless metadata?
    { jobType } = metadata
    return unless jobType?
    debug 'running jobType', jobType
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