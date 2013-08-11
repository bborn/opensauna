require 'test_helper'


class InterestWorkerTest < ActiveSupport::TestCase

  test 'should perform its job' do

    interest  = FactoryGirl.create(:interest)
    user      = interest.user
    topic     = interest.topics.first

    dashboard = interest.user.recommended_dashboard

    url       = FactoryGirl.create(:url)

    assert_equal(0, dashboard.url_references.count)

    worker = InterestWorker.new


    assert_difference "DashboardUrlWorker.jobs.count", 1 do
      worker.perform([topic.id], url.id)
    end

  end



end
