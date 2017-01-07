# frozen_string_literal: true

require 'rails_helper'

describe DbAdapter do
  it 'retrieves basic schema', :vcr do
    # use the vagrant box loaded with example database
    db = double(url: 'http://localhost:8080/nilmdb')
    adapter = DbAdapter.new(db.url)
    adapter.schema.each do |entry|
      expect(entry).to include(:path, :attributes)
      expect(entry[:attributes]).to(
        include(:data_type, :start_time,
                :end_time, :total_rows, :total_time)
      )
    end
  end
  
end
