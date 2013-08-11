
FactoryGirl.define do
  factory :interest do
    user_id { FactoryGirl.create(:user).id }
    topic_ids { [FactoryGirl.create(:topic).id] }
  end
end
