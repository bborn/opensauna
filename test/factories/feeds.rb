FactoryGirl.define do
  factory :feed do
    sequence(:uri) {|n| "http://www.feed.com/#{n}.rss" }
  end
end
