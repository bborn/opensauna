class FeedsController < SaunaController
  inherit_resources

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
    @urls = resource.urls.all.desc(:created_at).page(params[:page]||1).per(30)
    show!
  end

end
