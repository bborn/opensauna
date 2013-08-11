class TweetsController < SaunaController
  respond_to :html, :xml, :json
  
  before_filter :require_admin, :only => [:index, :show, :destroy]

  def score
    @tweet = Tweet.find(params[:id])
    @tweet.change_score(params[:score])
    redirect_to tweet_path(@tweet)
  end
  
  def show
    @tweet = Tweet.find(params[:id])
    
    @tweet.record_urls if params[:reprocess]
    
    respond_with(@tweet)
  end
  

  def destroy
    @tweet = Tweet.find(params[:id])
    @tweet.destroy

    respond_to do |format|
      format.html { redirect_to(root_path) }
    end
  end

  def index
    @tweets = Tweet.desc(:created_at).page(params[:page]||1).per(50)
  end

end