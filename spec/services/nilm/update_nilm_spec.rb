# frozen_string_literal: true

require 'rails_helper'

describe 'UpdateNilm' do
  it 'updates the db when NilmDB is accessible' do
    mock_service = instance_double(UpdateDb,
      run: StubService.new,
      errors: [],
      warnings: [])
    allow(UpdateDb).to receive(:new)
                   .and_return(mock_service)
    mock_adapter = double(JouleAdapter)
    allow(JouleAdapter).to receive(:new).and_return(mock_adapter)
    expect(mock_adapter).to receive(:module_info).and_return([])
    nilm = create(:nilm)
    service = UpdateNilm.new()
    service.run(nilm)
    expect(service.success?).to be true
  end
  it 'returns error if db is nil' do
    nilm = Nilm.create(name: 'test', url: 'invalid')
    mock_service = instance_double(UpdateDb,
      run: StubService.new)
    allow(UpdateDb).to receive(:new)
                   .and_return(mock_service)
    service = UpdateNilm.new()
    service.run(nilm)
    expect(service.success?).to be false
    expect(mock_service).to_not have_received(:run)
  end
  it 'returns error if db is offline' do
    nilm = create(:nilm)
    resp = StubService.new
    resp.add_error('offline')
    mock_service = instance_double(UpdateDb,
      run: resp)
    allow(UpdateDb).to receive(:new)
                   .and_return(mock_service)
    nilm = create(:nilm)
    service = UpdateNilm.new()
    service.run(nilm)
    expect(service.success?).to be false
  end

end
