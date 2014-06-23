class PostsController < ApplicationController
  load_and_authorize_resource :post,
    find_by: :slug,
    through: :current_site

  def index
    @posts = @posts.latest

    if params[:tag].present?
      @posts = @posts.tagged_with(params[:tag].gsub(/\+/, ' ').split.map(&:downcase))
    end

    respond_with @posts
  end

  def day
    date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    @posts = @posts.on_date(date).latest
    render 'index'
  end

  def show
    respond_with @post
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
    @post.update_attributes(post_params)
    respond_with @post
  end

  def post_params
    params.require(:post).permit(:body)
  end
end
