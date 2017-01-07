# frozen_string_literal: true

require 'rails_helper'
helper = DbSchemaHelper.new

describe 'UpdateStream service' do
  let(:db) { Db.new }
  let(:service) { UpdateDb.new(db: db) }

  it 'updates stream info' do
    # create Db with 1 folder and stream
    service.run([helper.entry('/folder1/stream1',
                              metadata: { name: 'old_name' })])
    stream = DbStream.find_by_name('old_name')
    expect(stream).to be_present
    # run update again with new metadata
    service = UpdateDb.new(db: db)
    service.run([helper.entry('/folder1/stream1',
                              metadata: { name: 'new_name' })])
    stream.reload
    expect(stream.name).to eq('new_name')
  end

  it 'updates element info' do
    # create Db with stream with 1 element
    schema = [helper.entry('/folder1/subfolder/stream',
                           element_count: 1)]
    schema[0][:elements][0][:name] = 'old_name'
    service.run(schema)
    element = DbElement.find_by_name('old_name')
    expect(element).to be_present
    # run update again with new metadata
    schema[0][:elements][0][:name] = 'new_name'
    service = UpdateDb.new(db: db)
    service.run(schema)
    element.reload
    expect(element.name).to eq('new_name')
  end
end
