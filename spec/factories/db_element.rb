# frozen_string_literal: true

# generic DbStream
FactoryGirl.define do
  factory :db_element do
    db_stream
    name { Faker::Lorem.word }
    scale_factor 1.0
    offset 0.0
  end
end
