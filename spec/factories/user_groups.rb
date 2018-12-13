FactoryBot.define do
  factory :user_group do
    transient do
      members { [] }
    end

    sequence :name do |n| "group#{n}" end
    description { Faker::Lorem.sentence }
    owner       { users.empty? ? create(:user): users.first }
    users       { members.empty? ? [create(:user)] : members }

    factory :test_user_group do
      transient do
        size { [] }
      end
      name { Faker::Company.unique.name }
      description { Faker::ChuckNorris.fact }
      owner { create(:confirmed_user) }
      users { size.times.map { create(:confirmed_user) } }
    end
  end


end
