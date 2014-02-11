class FancyApp.CommentsController extends Batman.Controller
  routingKey: 'comments'

  index: (params) ->
    FancyApp.Comment.cachedLoad { post_id: params.postId }, (err,results) =>
      @set 'comments', FancyApp.Comment.get('loaded').sortedBy('id','desc')

  show: (params) ->
    FancyApp.Comment.cachedFind parseInt(params.id, 10), (the_comment) =>
      @set 'comment', the_comment
    @render source: 'comments/show'

  new: (params) ->
    @set 'comment', new FancyApp.Comment(post_id: params.postId)
    @form = @render()

  create: (params) ->
    @get('comment').save (err,p) =>
      $('#new_comment').attr('disabled', false)

      if err
        throw err unless err instanceof Batman.ErrorsSet
      else
        FancyApp.flashSuccess "#{@get('comment.title')} created successfully!"
        @redirect "/posts/#{p.get('post_id')}"

  edit: (params) ->
    FancyApp.Comment.cachedFind parseInt(params.id, 10), (the_comment) =>
      @set 'comment', the_comment 
    @form = @render()

  update: (params) ->
    @get('comment').save (err,p) =>
      $('#edit_comment').attr('disabled', false)

      if err
        throw err unless err instanceof Batman.ErrorsSet
      else
        FancyApp.flashSuccess "#{@get('comment.title')} updated successfully!"
        @redirect "/posts/#{p.get('post_id')}"

  # not routable, an event
  destroy: ->
    comment = @get('comment')
    post_id = comment.get('post_id')

    comment.destroy (err) =>
      if err
        throw err unless err instanceof Batman.ErrorsSet
      else
        FancyApp.flashSuccess "Removed successfully!"
        @redirect "/posts/#{post_id}"

