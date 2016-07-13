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

  it 'removes streams destroyed' do
    stream = DbStream.create
    file = DbFile.create
    file.db_streams << stream
    file.destroy
    expect(DbStream.find_by_id(stream.id)).to be nil
  end

  describe 'remove' do
    let(:db_streams) { FactoryGirl.build_list(:db_stream, 5) }
    let(:db_file) { FactoryGirl.create(:db_file) }
    let(:db_service) { double(remove_file: true) }
    it 'destroys itself' do
      db_file.remove(db_service: db_service)
      expect(db_file).to be_destroyed
    end
    it 'destroys its db_streams' do
      db_file.db_streams << db_streams
      db_file.remove(db_service: db_service)
      db_streams.each do |stream|
        expect(stream).to be_destroyed
      end
    end
    it 'removes itself from the remote system using DbService' do
      db_file.remove(db_service: db_service)
      expect(db_service).to have_received(:remove_file)
    end
  end
end
