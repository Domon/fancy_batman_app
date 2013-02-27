# listens in on Pusher channels and hands it off to the ModelUpdater for processing
class Batmanpusher

  constructor: ->
    @pusher = new Pusher($('meta[name="pusher-key"]').attr('content'))
    @joinAppChannel()

  joinAppChannel: ->
    @channel = @safePusherJoin($('meta[name="pusher-channel"]').attr('content'))
    if @channel
      @channel.bind "updated",   (pushed_data) => @delayIfXhrRequests('updated', pushed_data)
      @channel.bind "created",   (pushed_data) => @delayIfXhrRequests('created', pushed_data)
      @channel.bind "destroyed", (pushed_data) => @delayIfXhrRequests('destroyed', pushed_data)
      @channel.bind "batched", (batch_data) => @delayIfXhrRequests('batched', batch_data)
      @channel.bind "flushed", (reload_data) => @delayIfXhrRequests('flushed', reload_data)

  safePusherJoin: (name) ->
    current_channels = _(@pusher.channels.channels).keys()
    if _(current_channels).include(name)
      FancyApp.current.logger.debug("Skipping join: #{name}")
    else
      @pusher.subscribe(name)

  delayIfXhrRequestsWithoutDecompress: (method, pushed_data) ->
    if Batmanpusher.activeXhrCount == 0
      setTimeout =>
        FancyApp.current.logger.debug("Processing #{method}")
        FancyApp.ModelUpdater.process(method,pushed_data)
      , 0
    else
      FancyApp.current.logger.debug("DELAYING #{method}")
      setTimeout =>
        @delayIfXhrRequestsWithoutDecompress(method, pushed_data)
      , 500

  delayIfXhrRequests: (method, payload) ->
    @delayIfXhrRequestsWithoutDecompress(method,payload)

@Batmanpusher = Batmanpusher
@Batmanpusher.activeXhrCount = 0
$(document).ajaxSend(=> @Batmanpusher.activeXhrCount++ ).ajaxComplete(=> @Batmanpusher.activeXhrCount--)