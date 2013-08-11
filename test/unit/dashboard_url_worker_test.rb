require 'test_helper'

class DashboardUrlWorkerTest < ActiveSupport::TestCase

  test 'should add url' do
    dash = create(:dashboard)
    url = create(:url)

    assert_difference "UrlReference.count", 1 do
      DashboardUrlWorker.new.perform(dash.id, url.id)
    end

    assert_equal dash.urls, [url]

  end


end
