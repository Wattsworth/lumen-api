# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'DbFolder' do
  describe 'object' do
    let(:db_folder) { DbFolder.new }
    # attributes
    specify { expect(db_folder).to respond_to(:name) }
    specify { expect(db_folder).to respond_to(:description) }
    specify { expect(db_folder).to respond_to(:hidden) }
    specify { expect(db_folder).to respond_to(:start_time) }
    specify { expect(db_folder).to respond_to(:end_time) }
    specify { expect(db_folder).to respond_to(:size_on_disk) }
    # associations
    specify { expect(db_folder).to respond_to(:parent) }
    specify { expect(db_folder).to respond_to(:subfolders) }
    specify { expect(db_folder).to respond_to(:db_streams) }
    specify { expect(db_folder).to respond_to(:db) }



  end

  describe 'when destroyed' do
    before(:all) do
      @folder = DbFolder.create
      @subfolder = DbFolder.create
      @stream = DbStream.create
      @folder.subfolders << @subfolder
      @folder.db_streams << @stream
      @folder.destroy
    end
    it 'removes subfolders' do
      expect(DbFolder.find_by_id(@subfolder.id)).to be_nil
    end
    it 'removes streams' do
      expect(DbStream.find_by_id(@stream.id)).to be_nil
    end
  end

  describe 'insert_stream' do
    let(:db_folder) { FactoryGirl.create(:db_folder) }
    let(:new_stream) { FactoryGirl.create(:db_stream) }

    it 'adds the stream to the folder' do
      db_folder.insert_stream(stream: new_stream)
      expect(new_stream.db_folder).to eq(db_folder)
    end
  end

  describe 'validation' do
    let(:db_folder) { FactoryGirl.create(:db_folder) }
    it 'forbids an empty name' do
      db_folder.name = ''
      expect(db_folder.valid?).to be false
    end
  end
end
