class AuthenticationExtrasController < SaunaController

  def update
    auth = current_user.authentications.find(params[:authentication_id])
    @extra = auth.extra
    @extra.managed_page_ids = params[:authentication_extra][:managed_page_ids]
    @extra.save!

    flash[:notice] = "Your changes were saved."
    redirect_to authentications_path
  end

end
