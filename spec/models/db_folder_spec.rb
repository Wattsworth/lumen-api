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
    let(:nilm) { FactoryBot.create(:nilm)}
    let(:db_folder) { FactoryBot.create(:db_folder, db: nilm.db) }
    let(:new_stream) { FactoryBot.build(:db_stream) }

    it 'adds the stream to the folder' do
      db_folder.insert_stream(stream: new_stream)
      expect(new_stream.db_folder).to eq(db_folder)
    end
  end

  describe 'validation' do
    let(:nilm) { FactoryBot.create(:nilm)}
    let(:db_folder) { FactoryBot.create(:db_folder, db: nilm.db) }
    it 'forbids an empty name' do
      db_folder.name = ''
      expect(db_folder.valid?).to be false
    end
    it 'name is unique in parent' do
      parent = DbFolder.create(name: 'parent')
      child1 = DbFolder.create(name: 'shared', parent: parent)
      child2 = DbFolder.new(name: 'shared', parent: parent)
      expect(child2.valid?).to be false
    end
  end
end
