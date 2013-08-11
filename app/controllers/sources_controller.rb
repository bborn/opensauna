# module MongoidActions
#   def collection
#     get_collection_ivar || set_collection_ivar(end_of_association_chain.all)
#   end
# end
# InheritedResources::Base.send :include, MongoidActions


class SourcesController < SaunaController
  inherit_resources

  def create_multiple
    params[:names].each_line do |name|
      @source = parent.sources.create(:name => name.strip)
    end
    redirect_to :action => "index"
  end

  def destroy
    @dashboard = Dashboard.find(params[:dashboard_id])
    resource.dashboards.delete(@dashboard)
    respond_to do |format|
      format.html{
        redirect_to inputs_dashboard_path(@dashboard)
      }
      format.js
    end
  end

  def show
    @tweets = resource.tweets.all.desc(:tweeted_at).page(params[:page]||1).per(20)
    @urls = resource.urls.all.desc(:published_at).page(params[:page]||1).per(20)
    show!
  end

end
