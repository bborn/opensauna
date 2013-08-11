FactoryGirl.define do
  factory :source do
    sequence(:name) {|n| "@twitteruser#{n}" }
  end
end
