class UsersController < SaunaController
  inherit_resources
  before_filter :require_admin, :only => [:destroy]
  skip_before_filter :check_guest_user, :only => [:edit, :update]
  respond_to :html, :js


  def update
    update! do |success, failure|

      success.html {
        @user.update_attribute(:lazy_id, nil)
        sign_in(@user, :bypass => true)
        redirect_to user_path(@user)
      }
      success.js {
        @user.update_attribute(:lazy_id, nil)
        sign_in(@user, :bypass => true)
        render :template => "users/update.js.erb"
      }
      failure.html { render :edit}
    end
  end


  def show
    @user = resource
  end

end
