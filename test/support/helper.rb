# FactoryGirl.find_definitions

ActiveSupport::Dependencies.clear
FactoryGirl.reload

require 'sidekiq/testing'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  teardown :clean_mongodb
  def clean_mongodb
    Mongoid.default_session.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
end
