class PostsController < ApplicationController
  # Add a couple of additional response formats.
  #
  respond_to :json
  respond_to :atom, only: [:index, :tagged]
  respond_to :js, only: [:index, :tagged]

  load_and_authorize_resource :post,
    find_by: :slug,
    through: :current_site

  # Hook up background processors to specific actions.
  #
  after_filter :fetch_referenced_posts, only: [:create, :update]
  after_filter :push_post, only: [:create, :update]

  def index
    @posts = @posts.latest.includes(:user)

    respond_with @posts do |format|
      format.html do
        @posts = @posts.blogged
      end

      format.atom do
        @posts = @posts.blogged
      end

      format.json do
        # updated_since parameter
        if params[:updated_since].present?
          @posts = @posts.where('edited_at >= ?', Time.at(params[:updated_since].to_i).to_datetime)
        end

        # always limit posts to a maximum of 100
        @posts = @posts.limit(100)
      end
    end
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
    @posts = @posts.latest.on_date(@date)
    @page_title = t('.page_title', date: l(@date, format: :long))

    respond_with @posts
  end

  def show
    with_canonical_url(post_url(@post, format: params[:format])) do
      @page_title = @post.title

      respond_with @post do |format|
        format.md { render text: @post.body }
      end
    end
  end

  def remote
    @url = params[:url]

    # First, try to load the post from the database
    @post = Post[@url]

    # If we haven't seen this post yet, or its last update was more than 1h ago, fetch it
    if @post.nil? || @post.updated_at < 1.hour.ago
      @post = PostFetcher.new(params[:url]).fetch!
    end

    render 'show'
  end

  def new
    @post.referenced_url = params[:referenced_url]
    respond_with @post
  end

  def create
    @post.save

    if @post.valid?
      # save the post
      @post.update_attributes(url: post_url(@post))

      # add post to my own timeline
      current_site.add_to_timeline(@post)
    end

    respond_with @post, location: :network
  end

  def edit
    respond_with @post
  end

  def update
    @post.update_attributes(post_params)
    @post.edited_at = Time.now

    if @post.valid?
      @post.update_attributes(url: post_url(@post))
    end

    respond_with @post
  end

  def destroy
    @post.destroy
    respond_with @post
  end

private

  def post_params
    params.require(:post).permit(:type, :body, :body_html, :referenced_url)
  end

  def fetch_referenced_posts
    if @post.valid?
      if @post.referenced_guid.present?
        # Fetch referenced post
        PostFetcher.new(@post.referenced_guid.with_http).async.fetch!
      end
    end
  end

  def push_post
    PostPusher.new(@post).async.push! if @post.valid?
  end
end
