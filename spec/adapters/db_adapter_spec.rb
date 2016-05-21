# frozen_string_literal: true

require 'rails_helper'

describe DbAdapter do
  it 'retrieves basic schema', :vcr do
    db = double(url: 'http://archive.wattsworth.net/nilmdb')
    adapter = DbAdapter.new(db.url)
    adapter.schema.map do |entry|
      expect(entry).to include(:path, :type, :start_time,
                               :end_time, :total_rows, :total_time, :metadata)
    end
  end
end
