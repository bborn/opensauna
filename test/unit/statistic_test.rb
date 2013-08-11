require 'test_helper'


class StatisticTest < ActiveSupport::TestCase

  test "should give the average Sources score with deviation" do
    dashboard = create(:dashboard)

    source = create(:source, :dashboards => [dashboard])
    source.change_score(2, dashboard.id)

    source2 = create(:source, :dashboards => [dashboard])
    source2.change_score(-20, dashboard.id)

    score = Statistic.average_source_score_with_deviation(dashboard)

    assert_equal score, [-9.0, 11.0]
  end


end
