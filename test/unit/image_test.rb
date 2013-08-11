require 'test_helper'

class ImageTest < ActiveSupport::TestCase

  test "be created" do
    url = create(:url)
    img = Image.new :attachable => url
    img.remote_file_url = "http://www.thisiscolossal.com/wp-content/uploads/2012/12/infra-1.jpg"
    img.save!

    assert_equal img.attachable, url
    assert img.file.thumb
  end

end
