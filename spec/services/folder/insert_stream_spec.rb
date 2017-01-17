# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'InsertStream' do
  describe 'insert_stream' do
    # mock the DbService and DbBuilder
    let(:db_service) { double(create_stream: true) }
    let(:db_builder) { double(build_path: '/test/file') }
    # a stream to insert
    let(:new_stream) { FactoryGirl.build_stubbed(:db_stream) }
    # a folder to insert it in
    let(:parent_folder) { FactoryGirl.build_stubbed(:db_folder) }

    it 'adds the given stream to the folder' do
      stream_inserter = InsertStream.new(db_service: db_service,
                                     db_builder: db_builder)
      stream_inserter.insert_stream(folder: parent_folder, stream: new_stream)
      expect(new_stream.db_folder).to eq(parent_folder)
    end

  end
end
