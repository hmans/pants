class PostsController < ApplicationController
  respond_to :json, only: :show
  respond_to :atom, only: :index

  load_and_authorize_resource :post,
    find_by: :slug,
    through: :current_site

  def index
    @posts = @posts.latest

    if params[:tag].present?
      @posts = @posts.tagged_with(params[:tag].gsub(/\+/, ' ').split.map(&:downcase))
    end
  end

  def day
    date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    @posts = @posts.on_date(date).latest
    render 'index'
  end

  def show
    canonical_path = post_path(@post, format: params[:format])
    if request.path != canonical_path
      redirect_to canonical_path and return
    end

    respond_with @post
  end

  def new
    respond_with @post
  end

  def create
    @post.save

    if @post.valid?
      @post.update_attributes(url: post_url(@post))
      PostPinger.new.async.perform(@post.id)
    end

    respond_with @post
  end

  def edit
    respond_with @post
  end

  def update
    @post.update_attributes(post_params)

    if @post.valid?
      @post.update_attributes(url: post_url(@post))
      PostPinger.new.async.perform(@post.id)
    end

    respond_with @post
  end

  def destroy
    @post.destroy
    respond_with @post
  end

  def post_params
    params.require(:post).permit(:body)
  end
end
