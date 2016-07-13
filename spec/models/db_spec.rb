# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Db' do
  describe 'object' do
    let(:db) { Db.new }
    specify { expect(db).to respond_to(:url) }
    specify { expect(db).to respond_to(:root_folder) }
  end

  it 'removes the root folder when destroyed' do
    root_folder = DbFolder.create
    db = Db.create(root_folder: root_folder)
    db.destroy
    expect(DbFolder.find_by_id(root_folder.id)).to be nil
  end
end
