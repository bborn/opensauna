# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :url do
    url "http://example.com/post/path/1234"
    title 'Blog post title'
    body 'Blog post body'
    html_body '<p>Blog post body</p>'
    titles ['Post title 1', 'Post title 2']
    lede 'This is the lede text'
    favicon 'favicon.ico'
    published_at Date.parse('Sat, 26 Feb 2011 08:59:10 -0600')
    cached_images ['http://bit.ly/image1', 'http://bit.ly/image2']
    image_count 2
    video_embeds ['<object></object>']
    description 'description of the blog post'
    keyword_list ['key', 'words', 'here']
    last_processed_at 1.day.ago
  end
end
