# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'DbStream' do
  describe 'object' do
    let(:db_stream) { DbStream.new }
    # attributes
    specify { expect(db_stream).to respond_to(:name) }
    specify { expect(db_stream).to respond_to(:name_abbrev) }
    specify { expect(db_stream).to respond_to(:description) }
    specify { expect(db_stream).to respond_to(:hidden) }
    specify { expect(db_stream).to respond_to(:size_on_disk) }
    # associations
    specify { expect(db_stream).to respond_to(:db_elements) }
    specify { expect(db_stream).to respond_to(:db) }


  end

  describe 'validation' do
    it 'requires a name' do
      stream = DbStream.new(name: '')
      stream.validate
      expect(stream.errors[:name].any?).to be true
    end
    it 'requires a unique name' do
      nilm = create(:nilm, name: "Test")
      DbStream.create(name: 'stream', db: nilm.db, db_folder: nilm.db.root_folder)
      stream2 = DbStream.new(name: 'stream', db: nilm.db, db_folder: nilm.db.root_folder)
      stream2.validate
      expect(stream2.errors[:name].any?).to be true
    end
    it 'requires a valid data type' do
      nilm = create(:nilm, name: "Test")
      my_stream = create(:db_stream, db: nilm.db,
                         db_folder: nilm.db.root_folder, name: 'invalid')
      my_stream.data_type = "float32_5"
      expect(my_stream).to_not be_valid
      expect(my_stream.errors.full_messages[0]).to include "5 elements"
    end
  end
  describe 'update' do
    it 'saves attributes to child elements' do
      stream = DbStream.create(name: 'stream', hidden: false)
      element = DbElement.create(name: 'A', db_stream: stream)
      new_attrs = {db_elements_attributes: [{id: element.id, units: 'new'}]}
      stream.assign_attributes(new_attrs)
      expect(stream.db_elements.first.units).to eq('new')
    end
  end

  describe 'meta_attributes' do
    it 'parses data format' do
      nilm = create(:nilm, name: "Test")
      my_stream = create(:db_stream, db: nilm.db,
                         db_folder: nilm.db.root_folder, name: 'invalid')
      my_stream.data_type="uint8_4"
      expect(my_stream).to be_valid
      expect(my_stream.data_format).to eq "uint8"
    end
    it 'parses column count' do
      nilm = create(:nilm, name: "Test")
      my_stream = create(:db_stream, db: nilm.db, db_folder: nilm.db.root_folder,
                         name: 'invalid', elements_count: 8)
      expect(my_stream.column_count).to eq 8
    end
  end

  describe 'child elements' do
    it 'are destroyed with  parent stream' do
      element = DbElement.create
      stream = DbStream.create
      stream.db_elements << element
      stream.destroy
      expect(DbElement.find_by_id(element.id)).to be nil
    end

    it 'exist for every column in stream datatype' do
      stream = DbStream.create(data_type: 'float32_3')
      stream.db_elements << DbElement.new
      # missing 3 elements
      expect(stream.valid?).to be false
    end

    it 'do not exist for columns not in stream datatype' do
      stream = DbStream.create(data_type: 'float32_1')
      2.times do |x|
        stream.db_elements << DbElement.new(column: x)
      end
      expect(stream.valid?).to be false
    end
  end
end
