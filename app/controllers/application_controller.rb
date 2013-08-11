
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_dashboard_slug
  before_filter :check_guest_user

  helper :all


  private
    # if user is logged in, return current_user, else return guest_user
    def current_or_guest_user(params)
      if current_user
        if cookies[:uuid]
          unless current_user.guest?
            cookies.delete :uuid
          end
        end
        current_user
      else
        guest_user(params)
      end
    end

    # find guest_user object associated with the current session,
    # creating one as needed
    def guest_user(params)
      if u = User.where(:lazy_id => true).where(:lazy_id => cookies[:uuid]).first
        u
      else
        create_guest_user(params)
      end
    end

    def create_guest_user(params)

      uuid = [Forgery::Basic.color, Forgery::Address.street_name.split(" ").first, rand(100)].join("-").downcase

      if params[:email].blank?
        temp_email = "#{uuid}@email_address.com"
      else
        temp_email = params[:email]
      end

      generated_password = Devise.friendly_token.first(6).to_s

      u = User.create(
        :email => temp_email,
        :lazy_id => uuid,
        :password => generated_password,
        :password_confirmation => generated_password,
        :invitation_token => params[:code]
      )

      u.save(:validate => false)
      cookies[:uuid] = { :value => uuid, :path => '/', :expires => 5.years.from_now }
      u
    end

    def set_dashboard_slug
      base_host_name = ENV['BASE_HOST_NAME'] || localhost

      request_host = request.host.gsub('www.', '')

      if base_host_name != request_host
        if request.host.include?(base_host_name)
          params[:dashboard_slug] = request.host.split('.')[0]
        elsif @dashboard = Dashboard.find_by(:custom_url => request.host)
          params[:dashboard_slug] = request.host
        end
      end

    end

    def check_guest_user
      if current_user && current_user.guest?
        flash.now[:alert] = "<i class='icon-warning-sign'></i> <strong>You're using a guest account.</strong> #{view_context.link_to('Please update your e-mail address and password.', main_app.edit_user_path(current_user, ), 'remote' => 'true', 'data-toggle' => 'modal', 'data-target' => '#modal-window')}"
      end
    end

    def require_admin
      redirect_to dashboards_path and return false unless current_user && current_user.admin?
    end


end
