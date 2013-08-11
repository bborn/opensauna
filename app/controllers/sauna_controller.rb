class SaunaController < ApplicationController
  before_filter :authenticate_user!, :except => [:home, :maintenance, :error]

  layout :set_layout, :except => [:home]
  layout 'dashboard', :only => [:home, :maintenance, :error]

  def home
    redirect_to dashboards_path and return if current_user
  end


  def navbar
    render :template => 'shared/_navbar', :layout => false and return
  end


  private
    def set_layout
      if request.headers['X-PJAX']
        'single'
      elsif
        'application'
      end
    end

end
