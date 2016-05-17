# frozen_string_literal: true

# generic DbStream
FactoryGirl.define do
  factory :db_stream do
    name { Faker::Lorem.word }
  end
end
