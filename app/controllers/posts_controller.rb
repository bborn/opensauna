class PostsController < SaunaController
  respond_to :html, :json, :js

  skip_before_filter :authenticate_user!, :only => [:show]

  def new
    @post = current_user.posts.new(params[:post]||{})

    if @url = @post.url
      @post.title  = @url.title
      @post.body   = "<blockquote>#{@url.description || @url.lede}</blockquote><p></p>"
      @post.images = @url.image_urls
    end
  end

  def show
    @post = current_user.posts.find(params[:id])
  end

  def edit
    @post = current_user.posts.find(params[:id])
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update_attributes(params[:post])
      redirect_to @post
    else
      render :action => "edit"
    end
  end

  def create
    @post = current_user.posts.new(params[:post]||{})

    if @post.save
      respond_to do |format|
        format.js
        format.html { redirect_to :action => 'index'}
      end
    else
      respond_to do |format|
        format.js
        format.html {render :action => "new"}
      end
    end
  end

  def index
    @posts = current_user.posts.desc(:created_at).page(params[:page]).per(50)
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy
    redirect_to :action => 'index'
  end

  def scheduled
    @posts = current_user.posts.where(:publish_at.ne => nil).where(:publish_at.gte => Time.now).asc(:publish_at).page(params[:page]).per(50)
  end



end
