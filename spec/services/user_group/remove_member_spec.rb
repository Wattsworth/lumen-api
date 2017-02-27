# frozen_string_literal: true

require 'rails_helper'

describe 'RemoveGroupMember service' do
  let(:owner) { create(:user) }
  let(:member1) { create(:user) }
  let(:member2) { create(:user) }
  let(:other_user) { create(:user) }
  let(:group) do
    create(:user_group,
           owner: owner,
           members: [member1, member2])
  end
  it 'removes specified user' do
    service = RemoveGroupMember.new
    service.run(group, member1.id)
    expect(service.success?).to be true
    expect(group.users.count).to eq(1)
    expect(group.users.include?(member1)).to be(false)
  end
  it 'errors if user is the owner' do
    service = RemoveGroupMember.new
    service.run(group, owner.id)
    expect(service.success?).to be false
    expect(group.reload.owner).to eq owner
  end
  it 'errors if user is not a member' do
    service = RemoveGroupMember.new
    service.run(group, other_user.id)
    expect(service.success?).to be false
  end
  it 'errors if user_id is invalid' do
    service = RemoveGroupMember.new
    service.run(group, 99) # bad user id
    expect(service.success?).to be false
  end
end
