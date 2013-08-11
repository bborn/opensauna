class HostConstaint

  def initialize(inverted = false)
    @inverted = inverted
    @base_host_name = ENV['BASE_HOST_NAME']
  end

  def matches?(req)
    req_host = req.host.gsub('www.', '')
    if @inverted

      return !req.parameters['dashboard_slug'] || (@base_host_name == req_host)
    else

      return req.parameters['dashboard_slug'] || (@base_host_name != req_host)
    end
  end

end


Sauna::Application.routes.draw do

  match '/maintenance' => "sauna#maintenance"
  match '/error' => "sauna#error"


  match '/admin/home' => 'admin#home'
  match '/admin/graph_data' => 'admin#graph_data'
  match '/purge_old_urls' => 'admin#purge_old_urls'
  match '/reprocess' => 'admin#reprocess', :as => 'reprocess_type'
  %w(sources feeds urls tweets dashboards).each do |type|
    match "/reprocess/#{type}/:id" => 'admin#reprocess', :as => "reprocess_#{type}", :type => type
  end


  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  constraint = lambda { |request| Rails.env.development? || (request.env["warden"].authenticate? and request.env['warden'].user.admin?) }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end


  match 'users/auth/facebook' => "users/omniauth_callbacks#facebook", :as => :facebook_omniauth_callback

  resources :users do
    member do
      match 'subscription'
    end
  end

  resources :authentications do
    resources :authentication_extras
  end

  resources :posts do
    collection do
      get 'scheduled'
    end
  end

  match "topics/choose" => "topics#choose", :as => "choose_topics"
  match "topics/user_profile(/:id)" => "topics#user_profile"

  resources :guests do
    member do
      match 'connect_to_twitter'
    end
  end

  resources :dashboards do
    member do
      match 'preview'
      match 'inputs'
      match 'stats'
      match 'graph_data'
      match 'url/:url_id' => 'dashboards#url', :as => 'dashboard_url'
      match 'theme'
      match 'posts', :as => 'dashboard_posts'
      match 'bookmarklet'
    end

    collection do
      match 'new_twitter'
      match 'new_fb'
    end

    resources :sources do
      collection do
        post 'create_multiple'
      end
    end

    resources :feeds
  end

  resources :feeds
  resources :sources
  resources :urls do
    member do
      get 'score'
      get 'story_panel'
      get 'share_panel'
    end
  end

  resources :tweets do
    member do
      get 'score'
    end
  end

  match '/browse/me' => 'dashboards#recommended', :as => 'browse_urls'

  match '/browse/:keyword' => 'urls#browse'
  match '/browse/' => 'urls#browse'

  match 'sauna/navbar' => 'sauna#navbar'


  root :to => 'dashboards#posts', :constraints => HostConstaint.new
  root :to => "sauna#home", :constraints => HostConstaint.new(true)

  match 'p/:post_id' => 'dashboards#post'
  match 'url/:url_id' => 'dashboards#url'



end
