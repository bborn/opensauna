

FactoryGirl.define do
  factory :url_reference do
    url_id { create(:url).id }
    dashboard_id { create(:dashboard).id }
  end
end
