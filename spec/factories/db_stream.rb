# frozen_string_literal: true

# generic DbStream
FactoryGirl.define do
  factory :db_stream do
    name { Faker::Lorem.word }
    data_type {"float32_1"}
  end
end
