# frozen_string_literal: true

require 'rails_helper'

describe DbAdapter do
  it 'retrieves basic schema', :vcr do
    db = double(url: 'http://archive.wattsworth.net/nilmdb')
    adapter = DbAdapter.new(db.url)
    adapter.schema.each do |entry|
      expect(entry).to include(:path, :attributes, :metadata)
      expect(entry[:attributes]).to(
        include(:data_type, :start_time,
                :end_time, :total_rows, :total_time))
    end
  end
end
