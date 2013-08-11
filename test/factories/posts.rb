FactoryGirl.define do
  factory :post do
    title 'This is a cool post'
    body "Here is the body"
    dashboard_id { create(:dashboard).id }
    publish_at DateTime.now
  end
end
