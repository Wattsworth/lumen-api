FactoryGirl.define do
  factory :user_group do
    transient do
      members []
    end

    sequence :name do |n| "group#{n}" end
    description { Faker::Lorem.sentence }
    owner       { users.empty? ? create(:user): users.first }
    users       { members.empty? ? [create(:user)] : members }
  end
end
