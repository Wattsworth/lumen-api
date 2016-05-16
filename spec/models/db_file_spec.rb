# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'DbFile' do
  describe 'object' do
    let(:db_file) { DbFile.new }
    specify { expect(db_file).to respond_to(:name) }
    specify { expect(db_file).to respond_to(:description) }
    specify { expect(db_file).to respond_to(:streams) }
  end

  describe 'remove' do
    let(:db_file) { DbFile.create }
    let(:db_service) { double(remove_file: true) }
    it 'destroys itself' do
      db_file.remove(db_service: db_service)
      expect(db_file).to be_destroyed
    end
    it 'removes itself from the remote system using DbService' do
      db_file.remove(db_service: db_service)
      expect(db_service).to have_received(:remove_file)
    end
  end
end
