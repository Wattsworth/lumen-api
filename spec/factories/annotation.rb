FactoryBot.define do
  factory :annotation do
    title { Faker::Lorem.words(number: 3).join(' ') }
    content { Faker::Lorem.sentence }
    start_time { Faker::Number.between(from: 1000, to: 2000) }
    end_time { Faker::Number.between(from: 3000, to: 4000)}
    id { Faker::Number.unique.number.to_i}
  end
end