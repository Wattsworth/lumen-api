# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'DbFolder' do
  describe 'object' do
    let(:db_folder) { DbFolder.new }
    specify { expect(db_folder).to respond_to(:name) }
    specify { expect(db_folder).to respond_to(:description) }
    specify { expect(db_folder).to respond_to(:parent) }
    specify { expect(db_folder).to respond_to(:subfolders) }
    specify { expect(db_folder).to respond_to(:db_files) }
  end

  describe 'insert_file' do
    let(:db_folder) { FactoryGirl.create(:db_folder) }
    let(:new_file) { FactoryGirl.create(:db_file) }

    it 'adds the file to subfolders' do
      db_folder.insert_file(file: new_file)
      expect(new_file.db_folder).to eq(db_folder)
    end
  end
end
