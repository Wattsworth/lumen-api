# frozen_string_literal: true

require 'rails_helper'

describe NodeAdapterFactory do
  # use the NUC office server
  let (:nilmdb_url) {'http://nuc/nilmdb'}
  let (:joule_url) {'http://nuc:8088'}

  it 'creates_adapter_from_nilm' do
    nilm = create(:nilm, node_type: 'nilmdb')
    adapter = NodeAdapterFactory.from_nilm(nilm)
    expect(adapter.node_type).to eq('nilmdb')

    nilm = create(:nilm, node_type: 'joule')
    adapter = NodeAdapterFactory.from_nilm(nilm)
    expect(adapter.node_type).to eq('joule')
  end

end