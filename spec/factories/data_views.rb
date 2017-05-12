FactoryGirl.define do
  factory :data_view do
    name { Faker::Lorem.words(3).join(' ') }
    description { Faker::Lorem.sentence }
    redux_json "auto generated from factory"
  end
end
