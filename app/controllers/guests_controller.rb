require 'digest/sha1'



class GuestsController < SaunaController
	skip_before_filter :authenticate_user!, :only => :new

	def new
		@user = current_or_guest_user(params)
		sign_in @user

    # redirect = current_user.twitter ? connect_to_twitter_guest_path(@user) : dashboards_path
		redirect = @user.interests.blank? ? choose_topics_path(:guest => true) : browse_urls_path

    # flash[:notice] = "We've signed you up with a guest account!"

    respond_to do |format|
			format.html {
				redirect_to redirect
			}
			format.js
		end
	end

	def connect_to_twitter
	end


	private


end
