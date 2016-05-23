{ DefaultMediaReceiver } = require 'castv2-client'

class Media
  constructor: ({ @client }) ->

  launch: ({ message }, callback) =>
    @client.launch DefaultMediaReceiver, (error, player) =>
      return callback error if error?
      media =
        contentId: message.media.mediaURL
        contentType: message.media.contentType
        streamType: message.media.streamType

      player.load media, { autoplay: message.autoplay, currentTime: message.currentTime }, (error, status) =>
        return callback error if error?
        callback null

module.exports = Media
