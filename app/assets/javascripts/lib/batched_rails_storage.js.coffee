# BatchedRailsStorage
# * automatically process batched changes that are passed in the environment
# * only works on Batman operations, like save, etc.
# If you are manually getting or posting, you will need to handle this in a callback:
#    $.post "/posts/#{@id()}/do_something.json", (results,status) =>
#      App.ModelUpdater.process('batched',results.batch)
class Batman.BatchedRailsStorage extends Batman.RailsStorage

  @::after 'all', @skipIfError (env, next) ->
    next()

    # Must be the last thing done, that is why next() is before this.
    if env.data? && env.data.batch?
      FancyApp.ModelUpdater.process('batched',env.data.batch)
