# frozen_string_literal: true

require 'rails_helper'

describe 'UpdateStream service' do
  let(:nilm) {create(:nilm, name: "test")}
  let(:db) { create(:db, nilm: nilm)}
  let(:service) { Nilmdb::UpdateDb.new(db) }
  let(:helper) { DbSchemaHelper.new }
  let(:mock_dbinfo) { {} }

  def build_entry(path, start, last, rows, width)
    helper.entry(path, start_time: start, end_time: last,
                 element_count: width, total_rows: rows)
  end


  it 'updates stream info' do
    # create Db with 1 folder and stream
    service.run(mock_dbinfo, [helper.entry('/folder1/stream1',
                              metadata: { name: 'old_name' })])
    stream = DbStream.find_by_name('old_name')
    expect(stream).to be_present
    # run update again with new metadata
    service = Nilmdb::UpdateDb.new(db)
    service.run(mock_dbinfo, [helper.entry('/folder1/stream1',
                              metadata: { name: 'new_name' })])
    stream.reload
    expect(stream.name).to eq('new_name')
    expect(stream.db).to eq(db)
  end

  it 'updates extent info' do
    # create a stream with 2 decimations
    # expect stream to have min_start => max_end duration
    # and size_on_disk to be sum of base+decimations

    service.run(mock_dbinfo,[build_entry('/a/path',            1,  90, 20, 8),
                 build_entry('/a/path~decim-4',   10, 110, 25, 24),
                 build_entry('/a/path~decim-16', -10, 100, 28, 24),
                 build_entry('/a/path~decim-64', nil, nil, 0, 24)])
    stream = DbStream.find_by_path('/a/path')
    expect(stream.start_time).to eq(-10)
    expect(stream.end_time).to eq(110)
    # (4*8+8)*20 + (4*24+8)*25 + (4*24+8)*28 + nothing
    expect(stream.size_on_disk).to eq(6312)
  end

  it 'updates element info' do
    # create Db with stream with 1 element
    schema = [helper.entry('/folder1/subfolder/stream',
                           element_count: 1)]
    schema[0][:elements][0][:name] = 'old_name'
    # add mandatory metadata ow it will be rejected
    schema[0][:elements][0][:scale_factor] = 1.0
    schema[0][:elements][0][:offset] = 0.0

    service.run(mock_dbinfo, schema)
    element = DbElement.find_by_name('old_name')
    expect(element).to be_present
    # run update again with new metadata
    schema[0][:elements][0][:name] = 'new_name'
    service = Nilmdb::UpdateDb.new(db)
    service.run(mock_dbinfo, schema)
    element.reload
    expect(element.name).to eq('new_name')
  end

  it 'uses default attributes if metadata is corrupt' do
    #metadata missing stream name and an element name
    bad_entry = helper.entry('/a/path',metadata: {name: ''})
    bad_entry[:elements] = [{column: 0, name: ''}]
    service.run(mock_dbinfo, [bad_entry])
    stream = DbStream.find_by_path('/a/path')
    expect(stream.name).to eq('/a/path')
    expect(stream.db_elements
                 .find_by_column(0)
                 .name).to eq('element0')
  end
end
