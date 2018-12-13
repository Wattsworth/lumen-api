# frozen_string_literal: true

# generic DbStream
FactoryBot.define do
  factory :db_element do
    name { Faker::Lorem.unique.words(3).join(' ') }
    units { 'volts' }
    sequence(:column)
    default_max { 100 }
    default_min { 0 }
    scale_factor { 1.0 }
    offset { 0.0 }
    plottable { true }
    display_type { 'continuous' }
  end
end
