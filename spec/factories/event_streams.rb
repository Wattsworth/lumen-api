FactoryBot.define do
  factory :event_stream do
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }

  end
end
