class PostsController < ApplicationController
  load_resource :post,
    find_by: :short_sha,
    through: :current_site

  def index
    @posts = @posts.fresh.order('created_at DESC')
    respond_with @posts
  end

  def show
    respond_with @post
  end

  def create
    @post.save
    respond_with @post
  end

  def edit
    respond_with @post
  end

  def update
    @successor = @post.dup
    @successor.created_at = @post.created_at
    @successor.attributes = post_params

    if @successor.valid? && @successor.sha != @post.sha
      @post.update_attributes(successor_sha: @successor.sha)
      @successor.save
      @post = @successor
    else
      @post.update_attributes(post_params)
    end

    respond_with @post
  end

  def post_params
    params.require(:post).permit(:body)
  end
end
