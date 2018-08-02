# frozen_string_literal: true

require 'rails_helper'

describe Joule::UpdateModules do

  before do
    raw = File.read(File.dirname(__FILE__)+"/test_module_schema.json")
    @schema = JSON.parse(raw).map{|item| item.deep_symbolize_keys}
  end
  it 'replaces existing modules with new ones' do
    nilm = create(:nilm)
    nilm.joule_modules << create(:joule_module, name: 'prev1')
    nilm.joule_modules << create(:joule_module, name: 'prev2')
    service = Joule::UpdateModules.new(nilm)
    service.run(@schema)
    expect(service.success?).to be true
    # new modules are in the database
    %w(Module1 Module2 Module3 Module4).each do |name|
      expect(nilm.joule_modules.find_by_name(name)).to be_present
    end
    # old ones are gone
    expect(JouleModule.count).to eq 4
    # pipes are updated as well
    m2 = nilm.joule_modules.find_by_name('Module2')
    expect(m2.joule_pipes.count).to eq 1
    m3 = nilm.joule_modules.find_by_name('Module3')
    expect(m3.joule_pipes.count).to eq 3
    # web interface status is correct
    expect(m2.web_interface).to be false
    expect(m3.web_interface).to be true
    # old pipes are gone
    expect(JoulePipe.count).to eq 9
  end
  it 'produces a warning if a stream is not in the database' do
    nilm = create(:nilm)
    service = Joule::UpdateModules.new(nilm)
    service.run(@schema)
    expect(service.warnings?).to be true
  end
  it 'links db_stream to the pipe if the stream is in the database' do
    nilm = create(:nilm)
    # create streams for pipe connections
    nilm.db.db_streams << create(:db_stream, path: '/folder_1/stream_1_1')
    nilm.db.db_streams << create(:db_stream, path: '/folder_1/stream_1_2')
    nilm.db.db_streams << create(:db_stream, path: '/folder_2/stream_2_1')
    service = Joule::UpdateModules.new(nilm)
    #just run module3
    service.run([@schema[0]])
    # make sure pipes are connected
    m3 = nilm.joule_modules.find_by_name('Module3')
    pipe = m3.joule_pipes.where(direction: 'input', name: 'input1').first
    expect(pipe.db_stream.path).to eq('/folder_1/stream_1_1')
    pipe = m3.joule_pipes.where(direction: 'input', name: 'input2').first
    expect(pipe.db_stream.path).to eq('/folder_1/stream_1_2')
    pipe = m3.joule_pipes.where(direction: 'output', name: 'output').first
    expect(pipe.db_stream.path).to eq('/folder_2/stream_2_1')
    expect(service.warnings?).to be false
  end
end
