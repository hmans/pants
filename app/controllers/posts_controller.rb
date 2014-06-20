class PostsController < ApplicationController
  load_and_authorize_resource

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
    @post.update_attributes(post_params)
    respond_with @post
  end

  def post_params
    params.require(:post).permit(:body)
  end
end
