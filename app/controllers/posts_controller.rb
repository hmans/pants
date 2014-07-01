class PostsController < ApplicationController
  respond_to :json, only: [:show, :index]
  respond_to :atom, only: [:index, :tagged]

  load_and_authorize_resource :post,
    find_by: :slug,
    through: :current_site

  after_filter :fetch_referenced_posts, only: [:create, :update]
  after_filter :push_to_local_followers, only: [:create, :update]

  def index
    @posts = @posts.latest.includes(:user)
    @date = @posts.any? ? @posts.first.published_at.to_date : Date.today

    respond_with @posts
  end

  def tagged
    @tags = params.require(:tag).gsub(/\+/, ' ').split.map(&:downcase)
    @all = params[:all].present?

    @posts = if @all
      Post.latest.tagged_with(@tags)
    else
      @posts.latest.tagged_with(@tags)
    end

    respond_with @posts
  end

  def day
    @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    @posts = @posts.latest
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
    @post.referenced_guid = params[:referenced_guid]
    respond_with @post
  end

  def create
    @post.save

    if @post.valid?
      # save the post
      @post.update_attributes(url: post_url(@post))

      # send pings for this post
      PostPinger.new.async.perform(@post.id)

      # add post to my own timeline
      current_site.add_to_timeline(@post)
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
    params.require(:post).permit(:body, :referenced_guid)
  end

private

  def fetch_referenced_posts
    if @post.referenced_guid.present?
      # Fetch referenced post
      PostFetcher.new.async.perform(@post.referenced_guid.with_http)

      # Ping referenced site with new post
      domain, slug = @post.referenced_guid.split '/'
      UserPinger.new.async.perform(domain, url: @post.url)
    end
  end

  def push_to_local_followers
    current_site.followers.hosted.find_each do |follower|
      follower.add_to_timeline(@post)
    end
  end
end
