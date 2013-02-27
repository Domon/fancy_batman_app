class FancyApp.PostsController extends Batman.Controller
  routingKey: 'posts'

  index: (params) ->
    FancyApp.Post.cachedLoad {}, (err,results) =>
      @set 'posts', FancyApp.Post.get('loaded').sortedBy('id','desc')

  show: (params) ->
    FancyApp.Post.cachedFind parseInt(params.id, 10), (the_post) =>
      @set 'post', the_post
    @render source: 'posts/show'

  new: (params) ->
    @set 'post', new FancyApp.Post()
    @form = @render()

  create: (params) ->
    @get('post').save (err,p) =>
      $('#new_post').attr('disabled', false)

      if err
        throw err unless err instanceof Batman.ErrorsSet
      else
        FancyApp.flashSuccess "#{@get('post.title')} created successfully!"
        @redirect "/posts/#{p.get('id')}"

  edit: (params) ->
    FancyApp.Post.cachedFind parseInt(params.id, 10), (the_post) =>
      @set 'post', the_post 
    @form = @render()

  update: (params) ->
    @get('post').save (err,p) =>
      $('#edit_post').attr('disabled', false)

      if err
        throw err unless err instanceof Batman.ErrorsSet
      else
        FancyApp.flashSuccess "#{@get('post.title')} updated successfully!"
        @redirect "/posts/#{p.get('id')}"

  # not routable, an event
  destroy: ->
    @get('post').destroy (err) =>
      if err
        throw err unless err instanceof Batman.ErrorsSet
      else
        FancyApp.flashSuccess "Removed successfully!"
        @redirect '/posts'