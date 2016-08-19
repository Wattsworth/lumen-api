# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'DbFile' do
  describe 'object' do
    let(:db_file) { DbFile.new }
    specify { expect(db_file).to respond_to(:name) }
    specify { expect(db_file).to respond_to(:name_abbrev) }
    specify { expect(db_file).to respond_to(:description) }
    specify { expect(db_file).to respond_to(:db_streams) }
    specify { expect(db_file).to respond_to(:hidden) }
  end

  describe 'child streams' do
    it 'are destroyed with  parent file' do
      stream = DbStream.create
      file = DbFile.create
      file.db_streams << stream
      file.destroy
      expect(DbStream.find_by_id(stream.id)).to be nil
    end

    it 'exist for every column in file datatype' do
      file = DbFile.create(data_type: 'float32_3')
      file.db_streams << DbStream.new
      # missing 3 streams
      expect(file.valid?).to be false
    end

    it 'do not exist for columns not in file datatype' do
      file = DbFile.create(data_type: 'float32_1')
      2.times do |x|
        file.db_streams << DbStream.new(column: x)
      end
      expect(file.valid?).to be false
    end
  end
end
