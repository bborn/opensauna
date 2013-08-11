FactoryGirl.define do
  factory :tweet do |f|
    sequence(:id_str) {|n| "#{n}" }
    text 'the text of the tweet, including a http://url.com'
    sequence(:cached_urls) {|n| ["http://url#{n}.com"] }
  end
end
