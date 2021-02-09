# frozen_string_literal: true

require 'rails_helper'

describe 'UpdateFolder service' do
  let(:nilm) {create(:nilm, name: "test")}
  let(:db) { create(:db, nilm: nilm)}
  let(:service) { Nilmdb::UpdateDb.new(db) }
  let(:helper) { DbSchemaHelper.new }
  let(:mock_dbinfo) { {} }

  def build_entry(path, start, last, rows, width)
    helper.entry(path, start_time: start, end_time: last,
                       element_count: width, total_rows: rows)
  end

  it 'updates folder info' do
    # create Db with folder and subfolder
    service.run(mock_dbinfo, [helper.entry('/folder1/subfolder/info',
                                           metadata: { name: 'old_name' })])
    folder = DbFolder.find_by_name('old_name')
    expect(folder).to be_present
    # run update again with new metadata
    service = Nilmdb::UpdateDb.new(db)
    service.run(mock_dbinfo, [helper.entry('/folder1/subfolder/info',
                                           metadata: { name: 'new_name' })])
    folder.reload
    expect(folder.name).to eq('new_name')
    expect(folder.db).to eq(db)
  end

  it 'updates extent info' do
    # create a stream with 2 decimations
    # expect stream to have min_start => max_end duration
    # and size_on_disk to be sum of base+decimations

    service.run(mock_dbinfo, [build_entry('/a/path', 1, 90, 20, 8),
                              build_entry('/a/path~decim-4', 10, 110, 25, 24),
                              build_entry('/a/path2', -10, 100, 28, 24),
                              # build_entry('/a/path',       nil, nil, 0, 24),
                              build_entry('/a/deep/path',       0, 400, 8, 10)])
    folder = DbFolder.find_by_path('/a')
    expect(folder.start_time).to eq(-10)
    expect(folder.end_time).to eq(400)
    # (4*8+8)*20 + (4*24+8)*25 + (4*24+8)*28 + (4*10+8)*8
    expect(folder.size_on_disk).to eq(6696)
  end

  it 'uses default attributes if metadata is missing' do
    service.run(mock_dbinfo, [helper.entry('/a/path', metadata: {})])
    folder = DbFolder.find_by_path('/a')
    expect(folder.name).to eq('a')
  end

  it 'uses default attributes if metadata is corrupt' do
    bad = { name: '' }
    service.run(mock_dbinfo, [helper.entry('/a/path'),
                              helper.entry('/a/info', metadata: bad)])

    folder = DbFolder.find_by_path('/a')
    expect(folder.name).to eq('/a')
  end
end
