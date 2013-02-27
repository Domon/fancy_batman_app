class FancyApp.Model extends Batman.Model
  @persist Batman.BatchedRailsStorage

  # cachedFind will return the object you are looking for
  @cachedFind: (id, callback) ->
    cachedItem = @get('loaded').indexedByUnique('id').get(parseInt(id))
    if cachedItem
      callback(cachedItem)
      return cachedItem
    @find(id,callback)

  # cachedLoad does NOT return a set of objects, it is meant to be called like:
  #  FancyApp.Post.cachedLoad {}, (err,results) =>
  #    @set 'posts', App.Post.get('loaded')
  # where additional options can be passed into the hash
  @cachedLoads: {}
  @cachedLoad: (options, callback) ->
    cacheKey = @resourceName
    for h, k of options
      cacheKey += h + k

    unless @cachedLoads[cacheKey]
      @cachedLoads[cacheKey] = true
      @load(options,callback)
    else
      callback() if callback

  id: =>
    @get("id")

  clone: ->
    temp = new @constructor
    temp.updateAttributes(@get('attributes').toObject())
    temp