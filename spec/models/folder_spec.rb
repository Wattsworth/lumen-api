require 'rails_helper'

RSpec.describe 'Folder' do
  it 'has a name' do
    folder = Folder.new(name: 'Test Folder')
    expect(folder.name).to eq('Test Folder')
  end
    
  it 'may have a description'
end
