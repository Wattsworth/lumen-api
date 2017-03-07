# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'factory_girl_rails'

# config.include FactoryGirl::Syntax::Methods

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

# create named users
def create_user(first_name, last_name)
  FactoryGirl.create(:confirmed_user,
                     first_name: first_name,
                     last_name: last_name)
end

john = create_user('John', 'Donnal')
john.email = 'jdonnal@gmail.com'
john.password = 'changeme'
john.save!

nicky = create_user('Nicky', 'Donnal')
steve = create_user('Steve', 'Leeb')
pete = create_user('Pete', 'Lindahl')
greg = create_user('Greg', 'Bredariol')

# create named groups
donnals = FactoryGirl.create(:user_group, name: 'Donnals', owner: john, members: [nicky])
lab = FactoryGirl.create(:user_group, name: 'Lab', owner: john, members: [steve, pete, greg])

# create real nilms
nc = CreateNilm.new
nc.run(name: 'Local', url: 'http://localhost:8080', owner: john)
home = nc.nilm
FactoryGirl.create(:permission, nilm: home, user_group: donnals, role: 'owner')
FactoryGirl.create(:permission, nilm: home, user: steve, role: 'viewer')

# create fake nilms
3.times { FactoryGirl.create(:nilm, admins: [john]) }
5.times { FactoryGirl.create(:nilm, owners: [john]) }
10.times { FactoryGirl.create(:nilm, viewers: [john])}
# create other groups
5.times do
  g = FactoryGirl.create(:test_user_group, size: rand(1..8))
  g.users << john #john joins every group!
end
