# frozen_string_literal: true

require 'rails_helper'

describe 'CreatePermission service' do

  let(:nilm){ create(:nilm)}
  let(:user){ create(:user)}
  let(:group){ create(:user_group)}

  it 'creates [role] permission for specified user' do
      service = CreatePermission.new
      service.run(nilm,'admin','user',user.id)
      p = service.permission
      expect(service.success?).to be true
      expect(p.valid?).to be true
      expect(p).to have_attributes(nilm: nilm,
                                   user: user,
                                   role: 'admin')
  end
  it 'creates [role] permission for specified group' do
      service = CreatePermission.new
      service.run(nilm,'admin','group',group.id)
      p = service.permission
      expect(service.success?).to be true
      expect(p.valid?).to be true
      expect(p).to have_attributes(nilm: nilm,
                                   user_group: group,
                                   role: 'admin')
  end
  it 'does not allow users multiple permissions on a nilm' do
    create(:permission, user: user, nilm: nilm, role: 'viewer')
    service = CreatePermission.new
    service.run(nilm,'admin','user',user.id)
    expect(service.success?).to be false
  end
  it 'does not allow groups multiple permissions on a nilm' do
    create(:permission, user_group: group, nilm: nilm, role: 'viewer')
    service = CreatePermission.new
    service.run(nilm,'admin','group',group.id)
    expect(service.success?).to be false
  end
  it 'verifies type in user|group' do
    service = CreatePermission.new
    service.run(nilm,'admin','bogus_type',0)
    expect(service.success?).to be false
    expect(service.errors[0]).to match(/type/)
  end

  it 'checks if user or group exists' do
    ['user','group'].each do |target_type|
      service = CreatePermission.new
      service.run(nilm,'admin',target_type,99)
      expect(service.success?).to be false
      expect(service.errors[0]).to match(/target/)
    end
  end

  it 'forwards permission errors' do
    service = CreatePermission.new
    service.run(nilm,'bad_role','user',user.id)
    p = service.permission
    expect(service.success?).to be false
    expect(service.errors).to eq(p.errors.full_messages)
  end
end
