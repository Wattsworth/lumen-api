# frozen_string_literal: true

require 'rails_helper'

describe 'UpdateJouleModules' do

  it 'replaces existing modules with new ones' do
    nilm = create(:nilm)
    nilm.joule_modules << create(:joule_module, name: 'prev1')
    nilm.joule_modules << create(:joule_module, name: 'prev2')
    adapter = MockJouleAdapter.new
    adapter.add_module("new1",inputs={i1: '/path/1'},
                              outputs={o1: '/path/2'})
    adapter.add_module("new2",inputs={i1: '/path/3',i2: '/path/4'},
                             outputs={o1: '/path/5',o2: '/path/5'})
    service = UpdateJouleModules.new(nilm)
    service.run(adapter.module_info)
    expect(service.success?).to be true
    # new modules are in the database
    expect(nilm.joule_modules.find_by_name('new1')).to be_present
    expect(nilm.joule_modules.find_by_name('new2')).to be_present
    # old ones are gone
    expect(JouleModule.count).to eq 2
    # pipes are updated as well
    n1 = nilm.joule_modules.find_by_name('new1')
    expect(n1.joule_pipes.count).to eq 2
    n2 = nilm.joule_modules.find_by_name('new2')
    expect(n2.joule_pipes.count).to eq 4
    # old pipes are gone
    expect(JoulePipe.count).to eq 6
  end
  it 'produces a warning if a stream is not in the database' do
    nilm = create(:nilm)
    adapter = MockJouleAdapter.new
    adapter.add_module("module",outputs={output: '/missing/path'})
    service = UpdateJouleModules.new(nilm)
    service.run(adapter.module_info)
    expect(service.warnings?).to be true
  end
  it 'links db_stream to the pipe if the stream is in the database' do
    nilm = create(:nilm)
    nilm.db.db_streams << create(:db_stream, path: '/matched/path1')
    nilm.db.db_streams << create(:db_stream, path: '/matched/path2')
    adapter = MockJouleAdapter.new
    adapter.add_module("module",inputs={input: '/matched/path1'},
                                outputs={output: '/matched/path2'})
    service = UpdateJouleModules.new(nilm)
    service.run(adapter.module_info)
    expect(service.warnings?).to be false
  end
  it 'returns error if Joule server is unavailable' do
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


end
