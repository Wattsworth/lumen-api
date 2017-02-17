# frozen_string_literal: true

# generic DbStream
FactoryGirl.define do
  factory :db_stream do
    name { Faker::Lorem.words(3) }
    name_abbrev { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    delete_locked false
    start_time { Faker::Number.number(6)}
    end_time { start_time + Faker::Number.number(5) }
    size_on_disk { Faker::Number.number(6) }
    hidden false
    path { "/root/streams/#{Faker::Lorem.unique.word}" }
    data_type { "float32_#{elements_count}" }

    transient do
      elements_count 4
    end

    after(:create) do |stream, evaluator|
      create_list(:db_element,
                  evaluator.elements_count,
                  db_stream: stream)
    end
  end
end
