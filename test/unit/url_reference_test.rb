require 'test_helper'

class UrlReferenceTest < ActiveSupport::TestCase


  test "queue worker when created" do
    assert_difference "UrlReferenceWorker.jobs.size", 1 do
      ref = create :url_reference
    end
  end

  test "classify itself" do
    ref = create :url_reference
    ref.classify
  end


end
