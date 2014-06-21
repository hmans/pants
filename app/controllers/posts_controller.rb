class PostsController < ApplicationController
  load_and_authorize_resource :post,
    find_by: :short_sha,
    through: :current_site

  def index
    @posts = @posts.fresh.latest
    respond_with @posts
  end

  def day
    date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    @posts = @posts.fresh.on_date(date).latest
    render 'index'
  end

  def show
    if @post.successor_sha.present? && cannot?(:manage, current_site)
      redirect_to @post.successor
    else
      respond_with @post
    end
  end

  def new
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
