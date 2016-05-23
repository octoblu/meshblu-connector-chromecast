getYouTubeId = require 'get-youtube-id'
debug        = require('debug')('meshblu-connector-chromecast:job-runner')
Media        = require './jobs/media'

class JobRunner
  constructor: ({ @client, jobType, @data }) ->
    jobs =
      # playYoutube:
      #   namespace: 'urn:x-cast:com.google.youtube.mdx'
      #   appId: '233637DE'
      #   method: =>
      # displayText:
      #   namespace: 'urn:x-cast:com.google.cast.sample.helloworld'
      #   appId: '794B7BBF'
      #   method: =>
      # displayURL:
      #   namespace: 'urn:x-cast:uk.co.splintered.urlcaster'
      #   appId: '7897BA3B'
      #   method: =>
      displayMedia:
        namespace: 'urn:x-cast:com.google.cast.media'
        appId: 'CC1AD845'
        method:  new Media({ @client }).launch

    @job = jobs[jobType]

    @requestId = Math.round(Math.random() * 10000)

  do: (callback) =>
    return callback 'Invalid Job Type' unless @job?
    debug 'running job'
    { appId, namespace, method } = @job
    method { message: @data }, callback

module.exports = JobRunner
