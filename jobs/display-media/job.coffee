http   = require 'http'
_      = require 'lodash'

class MediaJob
  constructor: ({@connector}) ->
    {@client} = @connector

  do: ({media, options}, callback) =>
    return callback @_userError(422, 'data.media is required') unless data.media?
    return callback @_userError(422, 'data.options is required') unless data.options?

    { media, options } = message
    @client.launch DefaultMediaReceiver, (error, player) =>
      return callback error if error?
      player.load media, options, (error, status) =>
        return callback error if error?
        callback null

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = MediaJob
