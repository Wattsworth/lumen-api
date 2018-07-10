# frozen_string_literal: true

require 'rails_helper'

describe 'EditStream service' do
  let(:mock_adapter) { instance_double(Nilmdb::Adapter) }
  let(:stream) { FactoryBot.create(:db_stream, path: '/stream/path', name: 'old') }
  let(:element) { stream.db_elements.first}
  let(:service) { EditStream.new(mock_adapter) }
  # db backend return values
  let(:success) { { error: false, msg: '' } }
  let(:error) { { error: true, msg: 'server error' } }

  it 'changes stream and element attributes' do
    attribs = { id: 0, invalid_attrib: 'ignore',
                name: 'new name', name_abbrev: 'nn',
              db_elements_attributes: [{id: element.id, name: 'new!'}] }
    allow(mock_adapter).to receive(:save_stream).and_return(success)
    # run the service, it should call the backend and save the folder
    service.run(stream, attribs)
    expect(mock_adapter).to have_received(:save_stream).with(stream)
    expect(stream.name).to eq('new name')
    expect(stream.name_abbrev).to eq('nn')
    expect(DbElement.find(element.id).name).to eq('new!')
  end

  it 'checks to make sure new attributes are valid' do
    attribs = { name: '' } # cannot have empty name
    allow(mock_adapter).to receive(:save_stream).and_return(success)
    # run the service, it shouldn't call the database backend
    service.run(stream, attribs)
    expect(service.errors?).to be true
    expect(mock_adapter).to_not have_received(:save_stream)
  end

  it 'does not change stream or elements on a server error' do
    attribs = { name: 'new',
                db_elements_attributes: [{id: element.id, name: 'new'}]}
    allow(mock_adapter).to receive(:save_stream).and_return(error)
    allow(stream).to receive(:save!)
    allow(element).to receive(:save!)
    # run the service, it shouldn't save the folder object
    service.run(stream, attribs)
    expect(service.errors?).to be true
    expect(stream).to_not have_received(:save!)
    expect(element).to_not have_received(:save!)
  end

end
