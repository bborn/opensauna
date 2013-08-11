source 'http://rubygems.org'

ruby '1.9.3'

gem 'rails', '3.2.11'
gem 'turbolinks'

gem 'compass'
gem 'sass-rails', '~> 3.2'
gem 'bootstrap-sass', '~> 2.3.1.0'

gem 'rails_admin'
gem 'httpclient'
gem "active_link_to", "~> 1.0.0"

gem "mongoid", "~> 3.0.3"
gem 'forgery', '0.5.0'

if ENV['BUNDLE_ENV'] == "dev"
  gem 'pismo', :path => '~/Projects/rails3.1/pismo'
  gem 'ankusa', :path => '~/Projects/rails3.1/ankusa'
  gem 'calais', :path => "~/Projects/rails3.1/calais"
else
  gem 'pismo', :git => 'git://github.com/bborn/pismo.git'
  gem 'ankusa', :git => 'https://github.com/bborn/ankusa.git'
  gem 'calais', :git => 'https://github.com/bborn/calais.git'
end

gem 'mongo'
gem 'state_machine'

gem 'jquery-rails', '~> 2.1'
gem 'unicorn'

group :development, :test do
  gem 'syntax'
  gem "factory_girl_rails", "~> 4.0"
  gem 'shoulda'
  gem 'mocha', :require => false
  gem 'sqlite3'
  gem 'foreman'
  gem "spork-rails"
  gem 'spork-testunit'
  gem 'simplecov', :require => false
  gem 'dotenv-rails'
end

gem "bson_ext", "~> 1.3"

gem "devise"
gem 'devise_invitable'

gem "haml"
gem "haml-rails"
gem 'bootstrap_forms', '3.0.0.rc1'
gem 'bootstrap-wysihtml5-rails'

gem 'coffee-rails'
gem 'pakunok'
gem 'knockout-rails'

group :assets do
  gem 'uglifier'
end

gem 'twitter', '4.3.0'
gem 'extractula', :git => 'git://github.com/bborn/extractula.git'

gem 'tactful_tokenizer'

gem 'redis'
gem 'redis-namespace'
gem 'yajl-ruby'
gem 'vegas'
gem 'json'

gem 'sidekiq'
gem 'sidekiq', :require => 'sidekiq/web'
gem 'sidekiq-failures'
gem 'sidekiq-unique-jobs'

gem 'filepicker-rails'

gem 'slim'
gem 'sinatra', :require => nil
gem "kiqstand"

gem 'kaminari'
gem 'mechanize'
gem 'opml_saw', :git => "git://github.com/feedbin/opml_saw.git", :branch => "master"


gem "feedzirra", '0.2.0.rc2'
gem "feedbag", "~> 0.9.1"
gem 'addressable'
gem 'postrank-uri', :git => "https://github.com/bborn/postrank-uri.git"

gem 'inherited_resources', '~> 1.3.0'
gem 'formtastic'

gem "omniauth", ">= 1.1.1"
gem "omniauth-twitter"
gem 'omniauth-facebook'

gem 'mini_fb'

gem 'hpricot'

gem 'memcachier'
gem 'dalli'
gem 'carrierwave'
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'

gem 'fog'
gem "mini_magick"

gem 'pg'
