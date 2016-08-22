# frozen_string_literal: true

require 'rails_helper'
helper = DbSchemaHelper.new

describe 'UpdateFolder service' do
  let(:db) { Db.new }
  let(:service) { UpdateDb.new(db: db) }

  it 'updates folder info' do
    # create Db with folder and subfolder
    service.run([helper.entry('/folder1/subfolder/info',
                              metadata: { name: 'old_name' })])
    folder = DbFolder.find_by_name('old_name')
    expect(folder).to be_present
    # run update again with new metadata
    service = UpdateDb.new(db: db)
    service.run([helper.entry('/folder1/subfolder/info',
                              metadata: { name: 'new_name' })])
    folder.reload
    expect(folder.name).to eq('new_name')
  end
end
