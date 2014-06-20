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
    @post.attributes = post_params

    if @post.valid? && @post.sha_changed?
      original_sha = @post.sha_was
      @post = @post.dup
      @post.parent_sha = original_sha
      @post.save
    else
      @post.save
    end

    respond_with @post, location: :root
  end

  def post_params
    params.require(:post).permit(:body)
  end
end
