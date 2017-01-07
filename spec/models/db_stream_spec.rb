# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'DbStream' do
  describe 'object' do
    let(:db_stream) { DbStream.new }
    specify { expect(db_stream).to respond_to(:name) }
    specify { expect(db_stream).to respond_to(:name_abbrev) }
    specify { expect(db_stream).to respond_to(:description) }
    specify { expect(db_stream).to respond_to(:db_elements) }
    specify { expect(db_stream).to respond_to(:hidden) }
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
