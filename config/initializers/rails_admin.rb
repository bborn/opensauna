# RailsAdmin config file. Generated on October 31, 2012 12:56
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|


  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = ['Sauna', 'Admin']
  # or for a more dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  # RailsAdmin may need a way to know who the current user is]
  config.current_user_method { current_user } # auto-generated

  config.authorize_with do
    redirect_to main_app.root_path unless current_user.admin?
  end

  # If you want to track changes on your models:
  # config.audit_with :history, 'User'

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, 'User'

  # Display empty fields in show views:
  # config.compact_show_view = false

  # Number of default rows per-page:
  # config.default_items_per_page = 20

  # Exclude specific models (keep the others):
  # config.excluded_models = ['Authentication']

  # Include specific models (exclude the others):
  # config.included_models = ['Authentication', 'Dashboard', 'Feed', 'Source', 'Statistic', 'Topic', 'Tweet', 'Url', 'User']

  # Label methods for model instances:
  # config.label_methods << :description # Default is [:name, :title]


  ################  Model configuration  ################

  # Each model configuration can alternatively:
  #   - stay here in a `config.model 'ModelName' do ... end` block
  #   - go in the model definition file in a `rails_admin do ... end` block

  # This is your choice to make:
  #   - This initializer is loaded once at startup (modifications will show up when restarting the application) but all RailsAdmin configuration would stay in one place.
  #   - Models are reloaded at each request in development mode (when modified), which may smooth your RailsAdmin development workflow.


  # Now you probably need to tour the wiki a bit: https://github.com/sferik/rails_admin/wiki
  # Anyway, here is how RailsAdmin saw your application's models when you ran the initializer:




  ###  Feed  ###

  # config.model 'Feed' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your feed.rb model definition

  #   # Found associations:

  #     configure :urls, :has_and_belongs_to_many_association
  #     configure :dashboard, :belongs_to_association

  #   # Found columns:

  #     configure :_type, :text         # Hidden
  #     configure :_id, :bson_object_id
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :name, :string
  #     configure :title, :string
  #     configure :uri, :string
  #     configure :score, :float
  #     configure :etag, :string
  #     configure :last_fetched_at, :datetime
  #     configure :last_modified, :datetime
  #     configure :url_ids, :serialized         # Hidden
  #     configure :dashboard_id, :bson_object_id         # Hidden

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Source  ###

  # config.model 'Source' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your source.rb model definition

  #   # Found associations:

  #     configure :tweets, :has_and_belongs_to_many_association
  #     configure :urls, :has_and_belongs_to_many_association
  #     configure :dashboard, :belongs_to_association

  #   # Found columns:

  #     configure :_type, :text         # Hidden
  #     configure :_id, :bson_object_id
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :name, :string
  #     configure :fb_uid, :string
  #     configure :last_fetched_at, :datetime
  #     configure :score, :float
  #     configure :tweet_ids, :serialized         # Hidden
  #     configure :url_ids, :serialized         # Hidden
  #     configure :dashboard_id, :bson_object_id         # Hidden

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Statistic  ###

  # config.model 'Statistic' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your statistic.rb model definition

  #   # Found associations:



  #   # Found columns:

  #     configure :_type, :text         # Hidden
  #     configure :_id, :bson_object_id
  #     configure :stat_key, :text
  #     configure :value, :float

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end




  ###  Topic  ###




  ###  Tweet  ###

  # config.model 'Tweet' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your tweet.rb model definition

  #   # Found associations:

  #     configure :sources, :has_and_belongs_to_many_association
  #     configure :urls, :has_and_belongs_to_many_association

  #   # Found columns:

  #     configure :_type, :text         # Hidden
  #     configure :_id, :bson_object_id
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :source_ids, :serialized         # Hidden
  #     configure :url_ids, :serialized         # Hidden
  #     configure :id_str, :integer
  #     configure :text, :string
  #     configure :cached_urls, :serialized
  #     configure :tweeted_at, :datetime
  #     configure :score, :float

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Url  ###

  # config.model 'Url' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your url.rb model definition

  #   # Found associations:

  #     configure :tweets, :has_and_belongs_to_many_association
  #     configure :feeds, :has_and_belongs_to_many_association
  #     configure :fb_sources, :has_and_belongs_to_many_association
  #     configure :topics, :has_and_belongs_to_many_association

  #   # Found columns:

  #     configure :_type, :text         # Hidden
  #     configure :_id, :bson_object_id
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :tweet_ids, :serialized         # Hidden
  #     configure :feed_ids, :serialized         # Hidden
  #     configure :fb_source_ids, :serialized         # Hidden
  #     configure :topic_ids, :serialized         # Hidden
  #     configure :url, :string
  #     configure :short_url, :string
  #     configure :titles, :serialized
  #     configure :title, :string
  #     configure :images, :serialized
  #     configure :video, :string
  #     configure :video_embeds, :serialized
  #     configure :lede, :string
  #     configure :description, :string
  #     configure :descriptions, :serialized
  #     configure :body, :string
  #     configure :html_body, :string
  #     configure :keywords, :string
  #     configure :keyword_list, :serialized
  #     configure :favicon, :string
  #     configure :published_at, :datetime
  #     configure :last_processed_at, :datetime
  #     configure :score, :float
  #     configure :classification, :serialized
  #     configure :tweets_count, :integer
  #     configure :cached_sources, :serialized
  #     configure :cached_feeds, :serialized
  #     configure :dashboard_ids, :serialized
  #     configure :facebook_shares, :integer

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  User  ###

  # config.model 'User' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your user.rb model definition

  #   # Found associations:

  #     configure :invited_by, :polymorphic_association         # Hidden
  #     configure :subscription_plan, :belongs_to_association
  #     configure :coupon, :belongs_to_association
  #     configure :authentications, :has_many_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :email, :string
  #     configure :password, :password         # Hidden
  #     configure :password_confirmation, :password         # Hidden
  #     configure :password_salt, :string         # Hidden
  #     configure :reset_password_token, :string         # Hidden
  #     configure :reset_password_sent_at, :datetime
  #     configure :remember_created_at, :datetime
  #     configure :sign_in_count, :integer
  #     configure :current_sign_in_at, :datetime
  #     configure :last_sign_in_at, :datetime
  #     configure :current_sign_in_ip, :string
  #     configure :last_sign_in_ip, :string
  #     configure :confirmation_token, :string
  #     configure :confirmed_at, :datetime
  #     configure :confirmation_sent_at, :datetime
  #     configure :unconfirmed_email, :string
  #     configure :failed_attempts, :integer
  #     configure :unlock_token, :string
  #     configure :locked_at, :datetime
  #     configure :authentication_token, :string
  #     configure :invitation_token, :string
  #     configure :invitation_sent_at, :datetime
  #     configure :invitation_accepted_at, :datetime
  #     configure :invitation_limit, :integer
  #     configure :invited_by_id, :integer         # Hidden
  #     configure :invited_by_type, :string         # Hidden
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :full_name, :string
  #     configure :vault_token, :string
  #     configure :subscription_plan_id, :integer         # Hidden
  #     configure :coupon_id, :integer         # Hidden
  #     configure :admin, :boolean
  #     configure :lazy_id, :string
  #     configure :dashboards_last_read, :text

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end

end
