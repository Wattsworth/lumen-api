# frozen_string_literal: true

require 'rails_helper'

describe NodeAdapterFactory do
  # use the NUC office server
  let (:nilmdb_url) {'http://nuc/nilmdb'}
  let (:joule_url) {'http://nuc:8088'}
  it 'creates_adapter_from_url', :vcr do
    adapter = NodeAdapterFactory.from_url(nilmdb_url)
    expect(adapter.node_type).to eq('nilmdb')
    adapter = NodeAdapterFactory.from_url(joule_url)
    expect(adapter.node_type).to eq('joule')
  end
  it 'returns nil with invalid url', :vcr do
    %w(http://www.google.com invalid_url).each do |url|
      expect(NodeAdapterFactory.from_url(url)).to be_nil
    end
  end
  it 'creates_adapter_from_nilm' do
    nilm = create(:nilm, node_type: 'nilmdb')
    adapter = NodeAdapterFactory.from_nilm(nilm)
    expect(adapter.node_type).to eq('nilmdb')

    nilm = create(:nilm, node_type: 'joule')
    adapter = NodeAdapterFactory.from_nilm(nilm)
    expect(adapter.node_type).to eq('joule')
  end

  it 'falls_back_to_url_when_node_type_is_invalid', :vcr do
    nilm = create(:nilm, url: joule_url)
    nilm.node_type='invalid'
    adapter = NodeAdapterFactory.from_nilm(nilm)
    expect(adapter.node_type).to eq('joule')
  end
end