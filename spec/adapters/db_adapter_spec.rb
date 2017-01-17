# frozen_string_literal: true

require 'rails_helper'

describe DbAdapter do
  # use the vagrant box loaded with example database
  let (:url) {'http://localhost:8080/nilmdb'}
  it 'retrieves basic schema', :vcr do
    adapter = DbAdapter.new(url)
    adapter.schema.each do |entry|
      expect(entry).to include(:path, :attributes)
      expect(entry[:attributes]).to(
        include(:data_type, :start_time,
                :end_time, :total_rows, :total_time)
      )
    end
  end
  describe 'set_folder_metadata' do
    it 'updates config_key in metadata', :vcr do
      adapter = DbAdapter.new(url)
      folder = DbFolder.new(path: '/tutorial',
      name: 'test', description: 'new')
      result = adapter.set_folder_metadata(folder)
      expect(result[:error]).to be false
    end
    it 'returns error on server failure', :vcr do
      adapter = DbAdapter.new(url)
      folder = DbFolder.new(path: '/badpath')
      result = adapter.set_folder_metadata(folder)
      expect(result[:error]).to be true
      expect(result[:msg]).to match(/badpath/)
    end
  end

end
