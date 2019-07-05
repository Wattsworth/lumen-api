FactoryBot.define do
  factory :annotation do
    title { Faker::Lorem.words(3).join(' ') }
    content { Faker::Lorem.sentence }
    start_time { Faker::Number.between(1000,2000) }
    end_time { Faker::Number.between(3000,4000)}
  end
end