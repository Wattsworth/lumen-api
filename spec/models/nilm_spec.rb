# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Nilm' do
  describe 'object' do
    let(:nilm) { Nilm.new }
    specify { expect(nilm).to respond_to(:name) }
    specify { expect(nilm).to respond_to(:description) }
    specify { expect(nilm).to respond_to(:url) }
    specify { expect(nilm).to respond_to(:db) }
  end

  it 'removes associated db when destroyed' do
    db = Db.create
    nilm = Nilm.create(db: db)
    nilm.destroy
    expect(Db.find_by_id(db.id)).to be nil
  end

  it 'removes associated permissions when destroyed' do
    nilm = create(:nilm)
    u = create(:user)
    g = create(:user_group)
    puser = create(:permission, nilm: nilm, user: u)
    pgrp = create(:permission, nilm: nilm, user_group: g)
    nilm.destroy
    [puser.id, pgrp.id].each do |id|
      expect(Permission.find_by_id(id)).to be nil
    end
  end
end
