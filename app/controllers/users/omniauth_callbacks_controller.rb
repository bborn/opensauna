class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController


  def twitter
    if current_user
      auth = User.connect_with_twitter_oauth(env["omniauth.auth"], current_user)
      if auth.valid?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"

        current_user.create_first_twitter_dashboard
        redirect_to dashboards_path
      else
        flash[:notice] = auth.errors.full_messages.to_sentence
        redirect_to connect_to_twitter_guest_path(current_user) and return
      end
    else
      redirect_to new_user_registration_path
    end
  end

  def facebook
    if current_user && User.connect_with_fb_oauth(env["omniauth.auth"], current_user)
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"

      if current_user.dashboards.empty?
        redirect_to dashboards_path
      else
        redirect_to authentications_path
      end
    else
      flash[:notice] = "Sorry, you have to be logged in to connect with Facebook"
      redirect_to new_user_registration_path
    end
  end

end
