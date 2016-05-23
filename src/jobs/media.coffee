{ DefaultMediaReceiver } = require 'castv2-client'

class Media
  constructor: ({ @client }) ->

  launch: ({ message }, callback) =>
    { media, options } = message
    @client.launch DefaultMediaReceiver, (error, player) =>
      return callback error if error?
      player.load media, options, (error, status) =>
        return callback error if error?
        callback null

module.exports = Media
