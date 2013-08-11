require 'test_helper'


class DashboardWorkerTest < ActiveSupport::TestCase

  test 'should perform its job' do

    dashboard = FactoryGirl.create(:dashboard)

    source = mock('Source')
    source.expects(:queue_worker).returns(true)

    feed = mock('Feed')
    feed.expects(:queue_worker).returns(true)


    dashboard.expects(:sources).returns([source])
    dashboard.expects(:feeds).returns([feed])

    Dashboard.expects(:find).with(dashboard.id).returns(dashboard)

    worker = DashboardWorker.new

    worker.perform(dashboard.id)

  end


end
