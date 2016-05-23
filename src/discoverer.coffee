utils           = require './utils'
mdns            = require 'mdns-js'
_               = require 'lodash'
{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-chromecast:discoverer')

class Discoverer extends EventEmitter
  discover: ({ @chromecastName, @autoDiscover }) =>
    return if @_isSameChromecast()
    return if @_discovering

    debug 'searching for chromecast...'
    @_discovering = true
    @browser = mdns.createBrowser(mdns.tcp('googlecast'));

    @browser.on 'update', (data) =>
      device = @_sanifyMDNS data
      return debug 'discovered non-chromecast device' unless @_chromecastType device
      @chromecast = @_getChromecast device
      return unless @chromecast?
      debug 'discovered chromecast device', @chromecast.name
      @_done()

    @browser.on 'ready', =>
      debug 'browser on ready'
      @browser.discover()

  _isSameChromecast: =>
    return true if @autoDiscover && @chromecast?
    return true if @chromecast? && utils.safeMatchString @chromecastName, @chromecast.name
    return false

  _done: (error) =>
    debug 'done searching', { error }
    @_discovering = false
    @browser?.stop()
    @emit 'error', error if error?
    @emit 'discover', @chromecast unless error?

  _chromecastType: (chromecast) =>
    return false unless 'googlecast' in chromecast.types
    return false unless chromecast.name?
    return true

  _getChromecast: (chromecast) =>
    return @chromecast if @chromecast?
    return chromecast if @autoDiscover
    return chromecast if utils.safeMatchString @chromecastName, chromecast.name
    return null

  _sanifyMDNS: (data={}) =>
    device = {}
    device.address = _.first data.addresses
    device.addresses = data.addresses
    device.name = data.host?.replace '.local', ''
    device.port = data.port
    txtRecord = {}
    items = data.txt
    _.each items, (item) =>
      return unless item?
      [key, value] = item.split '='
      txtRecord[key] = items[value]
    device.txtRecord = txtRecord
    device.types = _.map data.type, 'name'
    return device

module.exports = Discoverer
