# frozen_string_literal: true
FactoryBot.define do



  factory :nilm do
    #db
    name {Faker::Lorem.unique.words(number: 3).join(' ')}
    description { Faker::Lorem.sentence }
    url {Faker::Internet.unique.url}
    node_type { 'nilmdb' }
    key {Faker::Lorem.characters(number: 20)}

    transient do
      admins { [] }
      owners { [] }
      viewers { [] }
    end

    after(:create) do |nilm, evaluator|
      #root_folder = build :db_folder
      create :db, nilm: nilm

      evaluator.admins.each do |admin|
        if admin.instance_of? User
          create(:permission, user: admin, user_group: nil, nilm: nilm, role: "admin")
        else
          create(:permission, user_group: admin, user: nil, nilm: nilm, role: "admin")
        end
      end
      evaluator.owners.each do |owner|
        if owner.instance_of? User
          create(:permission, user: owner, user_group: nil, nilm: nilm, role: "owner")
        else
          create(:permission, user_group: owner, user: nil, nilm: nilm, role: "owner")
        end
      end
      evaluator.viewers.each do |viewer|
        if viewer.instance_of? User
          create(:permission, user: viewer, user_group: nil, nilm: nilm, role: "viewer")
        else
          create(:permission, user_group: viewer, user: nil, nilm: nilm, role: "viewer")
        end
      end
    end
  end
end
