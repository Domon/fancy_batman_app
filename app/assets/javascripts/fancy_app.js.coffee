window.FancyApp = class FancyApp extends Batman.App

  @title = "Fancy App"

  # changed again!
  Batman.config.viewPrefix = 'assets/batman/views'

  # get rid of DOM flicker
  Batman.DOM.Yield.clearAllStale = -> {}

  Batman.config.usePushState = yes
  Batman.config.pathPrefix = '/'

  @resources 'posts', ->
    @resources 'comments'

  @root 'posts#index'

  @on 'run', ->
    FancyApp.current.set 'logger', new Logger()

    # register the batman pusher
    FancyApp.current.set 'batmanpusher', new Batmanpusher()
    console?.log "Running ...."

  @on 'ready', ->
    console?.log "FancyApp ready for use."

  @flash: Batman()
  @flash.accessor
    get: (key) -> @[key]
    set: (key, value) ->
      @[key] = value
      if value isnt ''
        setTimeout =>
          @set(key, '')
        , 2000
      value

  @flashSuccess: (message) -> @set 'flash.success', message
  @flashError: (message) ->  @set 'flash.error', message
