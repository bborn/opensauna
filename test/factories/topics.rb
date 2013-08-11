
FactoryGirl.define do
  factory :topic do |f|
    f.sequence(:name) {|n| "#{n}Sports" }
    f.sequence(:alternate_names) { |n|
      ["#{n}Sport" ]
    }
  end
end
