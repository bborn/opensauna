require 'test_helper'

class DashboardTest < ActiveSupport::TestCase

  test "should add an array of inputs screennames and feed urls" do

    dashboard = create(:dashboard)

    inputs = ['name1', 'name2', 'http://example.com/rss']

    Source.expects(:screenname?).with('name1').returns(true)
    Source.expects(:screenname?).with('name2').returns(true)
    Source.expects(:screenname?).with('http://example.com/rss').returns(false)

    Feed.expects(:feed?).with('http://example.com/rss').returns('http://example.com/rss')

    assert_difference "Source.count", 1 do
      assert_difference "Feed.count", 1 do
        dashboard.add_inputs(inputs)
      end
    end
  end


  test 'should add urls in a background task' do
    dashboard = create(:dashboard)
    urls = [create(:url)]

    dashboard.add_urls_async(urls)

  end


  test 'should schedule a dashboard completed job after create' do

    assert_difference "Sidekiq::Extensions::DelayedClass.jobs.size", 1 do
      dashboard = create(:dashboard)
    end

  end

end
