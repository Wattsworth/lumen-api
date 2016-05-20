# frozen_string_literal: true

require 'rails_helper'

describe DbAdapter do
  it 'retrieves basic schema', :vcr do
    db = double(url: 'http://archive.wattsworth.net/nilmdb')
    adapter = DbAdapter.new(db.url)
    expect(adapter.schema).to include_json(error: true)
  end
end
