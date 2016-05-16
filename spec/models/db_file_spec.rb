require 'rails_helper'

RSpec.describe 'DbFile' do
  describe 'object' do
    let(:db_file) { DbFile.new }
    specify { expect(db_file).to respond_to(:name) }
    specify { expect(db_file).to respond_to(:description) }
    specify { expect(db_file).to respond_to(:streams) }
  end
end
