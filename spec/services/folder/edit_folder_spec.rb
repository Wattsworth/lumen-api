# frozen_string_literal: true

require 'rails_helper'

describe 'EditFolder service' do
  let(:mock_adapter) { }
  let(:service) { EditFolder.new(mock_adapter) }

  it 'changes folder attributes' do
    folder = DbFolder.new(name: 'old')
    service.run(folder,name: 'new')
    expect(mock_adapter).to be called once
    expect(folder.name).to eq('new')
  end
  
  it 'does not change folder on a server error' 

end