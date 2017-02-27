FactoryGirl.define do
  factory :user do
    first_name {Faker::Name.first_name}
    last_name {Faker::Name.first_name}
    email {Faker::Internet.unique.email}
    password {Faker::Lorem.characters(10)}

    factory :confirmed_user do
      confirmed_at {Time.now}
    end
  end


end
