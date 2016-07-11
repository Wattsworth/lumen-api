# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'InsertFile' do
  describe 'insert_file' do
    # mock the DbService and DbBuilder
    let(:db_service) { double(create_file: true) }
    let(:db_builder) { double(build_path: '/test/file') }
    # a file to insert
    let(:new_file) { FactoryGirl.build_stubbed(:db_file) }
    # a folder to insert it in
    let(:parent_folder) { FactoryGirl.build_stubbed(:db_folder) }

    it 'adds the given file to the folder' do
      file_inserter = InsertFile.new(db_service: db_service,
                                     db_builder: db_builder)
      file_inserter.insert_file(folder: parent_folder, file: new_file)
      expect(new_file.db_folder).to eq(parent_folder)
    end

    it 'does not add the file if the db_service fails'
  end
end
