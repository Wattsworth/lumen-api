FactoryGirl.define do
  factory :user_group do
    transient do
      members []
    end

    sequence :name do |n| "group#{n}" end
    description { Faker::Lorem.sentence }
    owner       { users.first }
    users       { members.empty? ? [User.first] : members }
  end
end
