class PostsController < ApplicationController
  load_and_authorize_resource

  def index
    @posts = @posts.order('created_at DESC')
    respond_with @posts
  end
end
