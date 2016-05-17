# frozen_string_literal: true

# generic DbFolder
FactoryGirl.define do
  factory :db_folder do
    name { Faker::Lorem.word }
  end
end
