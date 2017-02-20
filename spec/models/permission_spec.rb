# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Permission, type: :model do
  describe 'object' do
    let(:permission) { Permission.new }
    specify { expect(permission).to respond_to(:role) }
    specify { expect(permission).to respond_to(:nilm) }

    specify { expect(permission).to respond_to(:user_group) }
    specify { expect(permission).to respond_to(:user) }
  end

  it 'requires either a user or a group, not both' do
    u = create(:user)
    g = create(:user_group)
    n = create(:nilm)
    # valid with a user
    p = build(:permission, nilm: n, user: u)
    expect(p.valid?).to be true
    # valid with a group
    p.user = nil
    p.user_group = g
    expect(p.valid?).to be true
    # invalid with neither
    p.user_group = nil
    expect(p.valid?).to be false
    # invalid with both
    p.user_group = g
    p.user = u
    expect(p.valid?).to be false
    expect(p.errors.full_messages.first)
      .to match(/not both/)
  end

  it 'requires role to be viewer|owner|admin' do
    p = build(:permission)
    %w(owner viewer admin).each do |role|
      p.role=role
      expect(p.valid?).to be true
    end
    ['',nil,'other'].each do |invalid_role|
      p.role = invalid_role
      expect(p.valid?).to be false
    end
  end
  it 'responds to target_name' do
    u = create(:user, first_name: "John", last_name: "Donnal")
    p = build(:permission, user: u)
    expect(p.target_name).to match('John Donnal')
    g = create(:user_group, name: 'a group')
    p.user = nil; p.user_group = g
    expect(p.target_name).to match('a group')
  end
end
