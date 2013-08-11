# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "email#{n}@example.com" }
    password "test"
    password_confirmation "test"
  end
end
