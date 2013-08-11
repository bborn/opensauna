require 'test_helper'


class ScoreTest < ActiveSupport::TestCase

  test "should record a score for a url" do
    user = create :user
    url  = create :url

    assert_difference "Score.count", 1 do
      Score.score!(user.id, url.id, 1)
    end

    assert_equal(Score.last.score, 1)

  end


end
