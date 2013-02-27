# This is the beast that hooks into Batman's underlying model storage and 
# handles changes passed in from real time sources.
FancyApp.ModelUpdater =

  # private queue for jQuery
  _q: $({})

  # This is the public interface for updating objects in Batman in a bulk
  # or one off fashion
  process: (verb,batch_data) ->
    switch verb
      when "updated" then @['_updated'](batch_data)
      when "created" then @['_created'](batch_data)
      when "destroyed" then @['_destroyed'](batch_data)
      when "flushed" then @['_flushed'](batch_data)
      when "batched" then @['_batched'](batch_data)
      else
        FancyApp.current.logger.warn("unrecognized batch operation: " + verb)

  _enqueue: (batch_item) ->
    @_q.queue (next) =>
      @process(batch_item[0],batch_item[1])
      next()

  _getModelAndObject: (pushed_data) ->
    model = window.FancyApp[pushed_data.model_name]
    data = pushed_data.model_data
    obj = new model()
    obj._withoutDirtyTracking -> obj.fromJSON(data)
    return [model, obj]

  # flush every object of a certain model that matches the criterion (all comments for a post)
  # used when you have too much data to pass through Pusher but want Batman to request updates
  _flushed: (reload_data) ->
    model = window.FancyApp[reload_data.model_name]
    match_key = reload_data.match_key
    match_value =  reload_data.match_value
    FancyApp.current.logger.debug("FLUSH #{reload_data.model_name} - #{match_key} => #{match_value}")
    recordsToRemove = model.get('loaded').indexedBy(match_key).get(match_value).toArray()
    recordsToRemove.forEach (existing) =>
      model.get('loaded').remove(existing)
    if match_key == 'id'
      model.find match_value, ->
    else
      options = {}
      options["#{match_key}"] = match_value
      model.load options

  _batched: (batch_data) ->
    return if batch_data == undefined
    FancyApp.current.logger.debug("BATCH: " + batch_data.length)
    for batched_item in batch_data
      @_enqueue(batched_item)

  _created: (pushed_data) ->
    FancyApp.current.logger.debug("created: #{JSON.stringify(pushed_data)}")
    obj = window.FancyApp[pushed_data.model_name].get('loaded.indexedByUnique.id').get(pushed_data["model_data"]["id"])
    if obj # If object already in memory, update it
      obj._withoutDirtyTracking -> obj.fromJSON(pushed_data.model_data)
    else # create object in memory
      [model, obj] = @_getModelAndObject(pushed_data)
      model._mapIdentity(obj)

  _updated: (pushed_data) ->
    FancyApp.current.logger.debug("updated #{JSON.stringify(pushed_data)}")
    obj = window.FancyApp[pushed_data.model_name].get('loaded.indexedByUnique.id').get(pushed_data["model_data"]["id"])
    if obj
      obj._withoutDirtyTracking -> obj.fromJSON(pushed_data.model_data)

  _destroyed: (pushed_data) ->
    FancyApp.current.logger.debug("destroyed #{JSON.stringify(pushed_data)}")
    [model, obj] = @_getModelAndObject(pushed_data)
    existing = model.get('loaded').indexedByUnique('id').get(obj.get('id'))
    if existing
      model.get('loaded').remove(existing)
