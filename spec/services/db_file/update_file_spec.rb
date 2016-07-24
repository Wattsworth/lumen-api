# frozen_string_literal: true

require 'rails_helper'
helper = DbSchemaHelper.new

describe 'UpdateFile service' do
  let(:db) { Db.new }
  let(:service) { UpdateDb.new(db: db) }

  it 'updates file info' do
    # create Db with 1 folder and file
    service.run([helper.entry('/folder1/file1',
                              metadata: { name: 'old_name' })])
    file = DbFile.find_by_name('old_name')
    expect(file).to be_present
    # run update again with new metadata
    service = UpdateDb.new(db: db)
    service.run([helper.entry('/folder1/file1',
                              metadata: { name: 'new_name' })])
    file.reload
    expect(file.name).to eq('new_name')
  end

  it 'updates stream info' do
    # create Db with file with 1 stream
    schema = [helper.entry('/folder1/subfolder/file',
                           stream_count: 1)]
    schema[0][:streams][0][:name] = 'old_name'
    service.run(schema)
    stream = DbStream.find_by_name('old_name')
    expect(stream).to be_present
    # run update again with new metadata
    schema[0][:streams][0][:name] = 'new_name'
    service = UpdateDb.new(db: db)
    service.run(schema)
    stream.reload
    expect(stream.name).to eq('new_name')
  end
end
