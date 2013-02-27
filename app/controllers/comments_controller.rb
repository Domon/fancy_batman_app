class CommentsController < ApplicationController

  def index
    @post = Post.find(params[:post_id])
    @comments = @post.comments
    respond_to do |format|
      format.json { render :json => @comments}
    end
  end

  def show
    @comment = Comment.find(params[:id])
    respond_to do |format|
      format.json { render json: @comment.as_json }
    end
  end

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(params[:comment])
    respond_to do |format|
      if @comment.save
        format.json { render :json => @comment }
      else
        format.json { render :json => @comment.errors, :status => :unprocessable_entity}
      end
    end
  end

  def update
    @comment = Comment.find(params[:id])
    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.json { render :json => @comment }
      else
        format.json { render :json => @comment.errors, :status => :unprocessable_entity}
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    respond_to do |format|
      format.json { render json: {}, status: :ok}
    end
  end
end
