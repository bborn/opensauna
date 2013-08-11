require 'test_helper'

class PostTest < ActiveSupport::TestCase

  test "should update images from url" do
    url  = create :url
    url.cached_images = ['https://www.google.com/images/srpr/logo3w.png']
    url.scrape_images

    post = create :post
    post.url = url

    post.save
    post.update_images_from_url

    assert_equal(post.reload.images, url.image_urls)
  end

  test "should give publish_at options" do
    post = create :post
    user = create :user
    post.user_id = user.id
    post.save!

    assert_equal Post.publish_at_options.size, 9

  end


end

