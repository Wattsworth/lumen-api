# frozen_string_literal: true

# generic DbFolder
FactoryGirl.define do
  factory :db_folder, aliases: [:root_folder] do
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    start_time { Faker::Number.number(6)}
    end_time { start_time + Faker::Number.number(5) }
    size_on_disk { Faker::Number.number(6) }
    hidden false
    path { "/root/#{Faker::Lorem.unique.word}" }
  end
end
