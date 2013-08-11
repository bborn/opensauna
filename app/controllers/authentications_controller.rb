class AuthenticationsController < SaunaController

  def index
    @user = current_user
  end

  def new
    @authentication = current_user.authentications.new(params[:authentication])
  end

  def create
    @authentication = current_user.authentications.new(params[:authentication])
    if @authentication.save
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end



end
