# frozen_string_literal: true

require 'rails_helper'

describe 'UpdateNilm' do
  it 'updates the db when NilmDB is accessible' do
    mock_adapter = instance_double(Nilmdb::Adapter,
      refresh: StubService.new)
    nilm = create(:nilm)
    service = UpdateNilm.new(mock_adapter)
    service.run(nilm)
    expect(service.success?).to be true
  end
  it 'returns error if db is nil' do
    mock_adapter = instance_double(Nilmdb::Adapter)
    nilm = Nilm.create(name: 'test', url: 'invalid')
    service = UpdateNilm.new(mock_adapter)
    service.run(nilm)
    expect(service.success?).to be false
  end
  it 'returns error if db is offline' do
    resp = StubService.new
    resp.add_error('offline')
    mock_adapter = instance_double(Nilmdb::Adapter,
                                   refresh: resp)
    nilm = create(:nilm)
    service = UpdateNilm.new(mock_adapter)
    service.run(nilm)
    expect(service.success?).to be false
  end

end
