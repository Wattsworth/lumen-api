# frozen_string_literal: true

require 'rails_helper'

describe 'AddGroupMember service' do
  let(:owner) { create(:user) }
  let(:member1) { create(:user) }
  let(:member2) { create(:user) }
  let(:other_user) { create(:user) }
  let(:group) do
    create(:user_group,
           owner: owner,
           members: [member1, member2])
  end
  it 'adds specified user' do
    service = AddGroupMember.new
    service.run(group, other_user.id)
    expect(service.success?).to be true
    expect(group.users.count).to eq(3)
    expect(group.users.reload.include?(other_user)).to be(true)
  end
  it 'errors if user is the owner' do
    service = AddGroupMember.new
    service.run(group, owner.id)
    expect(service.success?).to be false
    expect(group.reload.owner).to eq owner
  end
  it 'errors if user is already a member' do
    service = AddGroupMember.new
    service.run(group, member1.id)
    expect(service.success?).to be false
  end
  it 'errors if user_id is invalid' do
    service = AddGroupMember.new
    service.run(group, 99) # bad user id
    expect(service.success?).to be false
  end
end
