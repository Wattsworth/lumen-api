# frozen_string_literal: true

# generic DbStream
FactoryBot.define do
  factory :db_stream do
    name { Faker::Lorem.words(number: 3).join(' ') }
    name_abbrev { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    delete_locked { false }
    start_time { Faker::Number.number(digits: 6).to_i}
    end_time { start_time + Faker::Number.number(digits: 5).to_i }
    total_time {end_time - start_time}
    size_on_disk { Faker::Number.number(digits: 6).to_i }
    hidden { false }
    path { "/root/streams/#{Faker::Lorem.unique.word}" }
    data_type { "float32_#{elements_count}" }

    transient do
      elements_count { 4 }
      decimations_count { 0 }
    end

    after(:create) do |stream, evaluator|
      create_list(:db_element,
                  evaluator.elements_count,
                  db_stream: stream)
      evaluator.decimations_count.times do |x|
        create(:db_decimation,
        db_stream: stream,
        start_time: stream.start_time,
        end_time: stream.end_time,
        level: 4**(x+1))
      end
    end
  end
end
