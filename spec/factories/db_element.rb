# frozen_string_literal: true

# generic DbStream
FactoryGirl.define do
  factory :db_element do
    name { Faker::Lorem.unique.words(3) }
    units 'volts'
    sequence(:column)
    default_max 100
    default_min 0
    scale_factor 1.0
    offset 0.0
    plottable true
    discrete false
  end
end
