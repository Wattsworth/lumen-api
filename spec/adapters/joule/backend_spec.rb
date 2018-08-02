# frozen_string_literal: true

require 'rails_helper'

describe Joule::Backend do
  # use the benchtop server joule API
  let (:url) {'http://nuc:8088'}
  it 'retrieves database schema', :vcr do
    backend = Joule::Backend.new(url)
    schema = backend.db_schema
    # make sure keys are symbolized
    expect(schema).to include(:name, :id, :streams, :children)
    # should be a tree structure
    expect(schema[:children][0]).to include(:name, :id, :streams, :children)
  end
  it 'retrieves module schema', :vcr do
    backend = Joule::Backend.new(url)
    backend.module_schemas.each do |m|
      expect(m).to include(:name, :inputs, :outputs)
    end
  end

  it 'loads raw data', :vcr do
    backend = Joule::Backend.new(url)
    resp = backend.load_data(6,
                             1531248642561047,
                             1531248642581047,
                             200)
    expect(resp[:decimated]).to be false
    expect(resp[:data].count).to be > 0
    expect(resp[:data].count).to be < 200
  end

  it 'loads decimated data', :vcr do
    backend = Joule::Backend.new(url)
    resp = backend.load_data(6,
                             1531248642561047,
                             1531330705273202,
                             20)
    expect(resp[:decimated]).to be true
    expect(resp[:data].count).to be > 0
    expect(resp[:data].count).to be < 200
  end
end
