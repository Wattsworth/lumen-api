# frozen_string_literal: true

FactoryBot.define do
  factory :db do
    url { "" }
    max_points_per_plot { Faker::Number.number(digits: 3) }
    size_db { Faker::Number.number(digits: 5) }
    size_other { Faker::Number.number(digits: 5) }
    size_total { size_db + size_other }
    available { true }
    root_folder
  end
end
