FactoryBot.define do
  factory :data_app do
    joule_id { Faker::Number.number(digits: 6).to_i}
  end
end
