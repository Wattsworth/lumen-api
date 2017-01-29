# frozen_string_literal: true

require 'rails_helper'

describe 'EditFolder service' do
  let(:db_adapter) { instance_double(DbAdapter) }
  let(:folder) { DbFolder.new(path: '/folder/path', name: 'old') }
  let(:service) { EditFolder.new(db_adapter) }
  # db adapter return values
  let(:success) { { error: false, msg: '' } }
  let(:error) { { error: true, msg: 'server error' } }

  it 'changes folder attributes' do
    attribs = { id: 0, invalid_attrib: 'ignore',
                name: 'new', description: 'updated' }
    allow(folder).to receive(:save!)
    allow(db_adapter).to receive(:set_folder_metadata).and_return(success)
    # run the service, it should call the adapter and save the folder
    service.run(folder, attribs)
    expect(db_adapter).to have_received(:set_folder_metadata).with(folder)
    expect(folder.name).to eq('new')
    expect(folder.description).to eq('updated')
    expect(folder).to have_received(:save!)
  end

  it 'checks to make sure new attributes are valid' do
    attribs = { name: '' } # cannot have empty name
    allow(db_adapter).to receive(:set_folder_metadata).and_return(success)
    # run the service, it shouldn't call the database adapter
    service.run(folder, attribs)
    expect(service.errors?).to be true
    expect(db_adapter).to_not have_received(:set_folder_metadata)
  end

  it 'does not change folder on a server error' do
    attribs = { name: 'new' }
    allow(db_adapter).to receive(:set_folder_metadata).and_return(error)
    allow(folder).to receive(:save!)
    # run the service, it shouldn't save the folder object
    service.run(folder, attribs)
    expect(service.errors?).to be true
    expect(folder).to_not have_received(:save!)
  end
end
