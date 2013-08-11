FactoryGirl.define do
  factory :dashboard do
    sequence(:name) {|n| "dashboard#{n}" }
    user_id { create(:user).id }
  end
end
