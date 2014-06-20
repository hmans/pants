class PostsController < ApplicationController
  load_and_authorize_resource :post,
    find_by: :short_sha

  def index
    @posts = @posts.order('created_at DESC')
    respond_with @posts
  end

  def show
    respond_with @post
  end

  def create
    @post.save
    respond_with @post, location: :root
  end

  def edit
    respond_with @post
  end

  def update
    @successor = @post.dup
    @successor.attributes = post_params

    if @successor.valid? && @successor.sha != @post.sha
      @post.update_attributes(successor_sha: @successor.sha)
      @successor.save
      @post = @successor
    else
      @post.update_attributes(post_params)
    end

    respond_with @post, location: :root
  end

  def post_params
    params.require(:post).permit(:body)
  end
end
