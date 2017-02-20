# frozen_string_literal: true

require 'rails_helper'

describe 'DestroyPermission service' do

  let(:requester){ create(:user)}
  let(:viewer){ create(:user)}
  let(:group){ create(:user_group)}
  let(:nilm){ create(:nilm,
                     admins:[requester],
                     viewers:[viewer, group])}

  it 'removes specified user permission from nilm' do
    expect(viewer.views_nilm?(nilm)).to be true
    service = DestroyPermission.new
    p = nilm.permissions.where(user: viewer).first
    service.run(nilm,requester,p.id)
    expect(service.success?).to be true
    expect(viewer.views_nilm?(nilm)).to be false
  end
  it 'removes specified group permission from nilm' do
    expect(group.permissions).to be_empty
    service = DestroyPermission.new
    p = nilm.permissions.where(user_group: group).first
    service.run(nilm,requester,p.id)
    expect(service.success?).to be true
    expect(group.permissions).to be_empty
  end
  it 'returns error if permission is not on nilm' do
    nilm2 = create(:nilm, admins: [viewer])
    p2 = nilm2.permissions.first
    service = DestroyPermission.new
    service.run(nilm,requester,p2.id)
    expect(service.success?).to be false
    expect(Permission.find(p2.id)).to be_present
  end
  it 'does not allow requester to delete himself' do
    service = DestroyPermission.new
    p = nilm.permissions.where(user: requester).first
    service.run(nilm,requester,p.id)
    expect(service.success?).to be false
    expect(requester.admins_nilm?(nilm)).to be true
  end
end
