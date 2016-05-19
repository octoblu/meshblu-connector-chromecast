utils           = require './utils'
mdns            = require 'mdns-js'
_               = require 'lodash'
{EventEmitter}  = require 'events'

class Chromecast extends EventEmitter
  constructor: ({ @chromecastName, @autoDiscover }) ->


  discover: (callback) =>
    cleanUpAndCallback = @_cleanUpAndCallback callback
    @browser = mdns.createBrowser(mdns.tcp('googlecast'));

    @browser.on 'update', (data) =>
      @chromecast = @_getChromecast @_sanifyMDNS data
      return cleanUpAndCallback(new Error('Unable to find chromecast')) unless @chromecast?

    @browser.on 'ready', =>
      @browser.discover()

  _cleanUpAndCallback: (callback) =>
    return (error, data) =>
      @browser.stop()
      callback(error, data)

  _getChromecast: (chromecast) =>
    return null unless 'googlecast' in chromecast.types
    return null unless chromecast.name?
    return @chromecast if @chromecast.name == @chromecastName
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
    _.each data.txt, (item) =>
      return unless item?
      [key, value] = item.split '='
      txtRecord[key] = items[value]
    device.txtRecord = txtRecord
    device.types = _.pluck data.type, 'name'
    return device

module.exports = Chromecast
